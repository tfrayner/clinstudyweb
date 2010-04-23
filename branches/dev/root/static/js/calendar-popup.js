var calendarObjForForm = new DHTMLSuite.calendar({minuteDropDownInterval:10,numberOfRowsInHourDropDown:5,callbackFunctionOnDayClick:'getDateFromCalendar',isDragable:true}); 
calendarObjForForm.setCallbackFunctionOnClose('myOtherFunction');

function myOtherFunction(){}
function pickDate(buttonObj,inputObject)
{
    calendarObjForForm.setCalendarPositionByHTMLElement(inputObject,0,inputObject.offsetHeight);
    calendarObjForForm.setInitialDateFromInput(inputObject,'yyyy-mm-dd');
    calendarObjForForm.addHtmlElementReference('myDate',inputObject);
    if(calendarObjForForm.isVisible()){
        calendarObjForForm.hide();
    }else{
        calendarObjForForm.resetViewDisplayedMonth();
        calendarObjForForm.display();
    }
}
function getDateFromCalendar(inputArray)
{
    var references = calendarObjForForm.getHtmlElementReferences(); // Get back reference to form field.
    references.myDate.value = inputArray.year + '-' + inputArray.month + '-' + inputArray.day;
    calendarObjForForm.hide();
}
