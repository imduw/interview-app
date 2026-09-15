function doGet() {
  return ContentService
    .createTextOutput(JSON.stringify({
      success: true,
      message: 'Interview App backend is ready.'
    }))
    .setMimeType(ContentService.MimeType.JSON);
}

function doPost(e) {
  try {
    const raw = e && e.postData && e.postData.contents ? e.postData.contents : '{}';
    const payload = JSON.parse(raw);
    const spreadsheetId = PropertiesService.getScriptProperties().getProperty('SHEET_ID');

    if (!spreadsheetId) {
      throw new Error('Missing SHEET_ID in Apps Script properties. Please configure it first.');
    }

    const ss = SpreadsheetApp.openById(spreadsheetId);
    const sheet = ss.getSheetByName('Interviews') || ss.insertSheet('Interviews');

    if (sheet.getLastRow() === 0) {
      sheet.appendRow([
        'id',
        'sessionName',
        'interviewerName',
        'intervieweeName',
        'dateTime',
        'questions',
        'answers',
        'latitude',
        'longitude',
        'photo',
        'syncStatus'
      ]);
    }

    const id = String(payload.id || '');
    if (!id) {
      throw new Error('Missing id');
    }

    const existing = sheet.getDataRange().getValues();
    let duplicate = false;
    for (let i = 1; i < existing.length; i += 1) {
      if (String(existing[i][0]) === id) {
        duplicate = true;
        break;
      }
    }

    if (duplicate) {
      return ContentService
        .createTextOutput(JSON.stringify({
          success: true,
          message: 'Duplicate ignored',
          duplicate: true,
          id: id
        }))
        .setMimeType(ContentService.MimeType.JSON);
    }

    const questionList = Array.isArray(payload.questions) ? payload.questions : [];
    const answerList = questionList.map(function (q) {
      return q && q.answer ? q.answer : '';
    });

    let photoUrl = '';
    if (payload.photo) {
      const mimeType = 'image/jpeg';
      const blob = Utilities.newBlob(Utilities.base64Decode(payload.photo), mimeType, id + '.jpg');
      const file = DriveApp.createFile(blob);
      photoUrl = file.getUrl();
    }

    sheet.appendRow([
      id,
      payload.sessionName || '',
      payload.interviewerName || '',
      payload.intervieweeName || '',
      payload.dateTime || '',
      JSON.stringify(questionList),
      JSON.stringify(answerList),
      payload.latitude == null ? '' : payload.latitude,
      payload.longitude == null ? '' : payload.longitude,
      photoUrl,
      payload.syncStatus || 'pending'
    ]);

    return ContentService
      .createTextOutput(JSON.stringify({
        success: true,
        message: 'Interview synced successfully',
        id: id
      }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService
      .createTextOutput(JSON.stringify({
        success: false,
        error: error && error.message ? error.message : String(error)
      }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
