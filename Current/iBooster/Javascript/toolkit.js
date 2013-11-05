/*Blah blah gpl shit*/

var iBoosterToolkit = {};

iBoosterToolkit.getUsername = function() {
    var usernameDiv = document.querySelector("#ctl00_lnkMyBoosterForm");
    if(usernameDiv == null) {
        return null;
    }
    return usernameDiv.innerHTML;
}

iBoosterToolkit.checkIfLoggedIn = function () {
    //Si on est connecté, on atteris sur une page qui dans le header contient un lien qui a pour ID "ctl00_lnkMyBoosterForm"
    //On ne verifie pas l'url, cette methode suffit amplement
    if(iBoosterToolkit.getUsername() != null) {
        return true;
    } else {
        return false;
    }
}

iBoosterToolkit.parseMarksLevels = function () {
    var marksContainer = $("#ctl00_ContentPlaceHolder1_Lab1_ctl01_fstMain");
    if(marksContainer.length == 0) {
        return {"error": true};
    }
    marksContainer = null;
    var parsedLevels = [];
    var i = 1;
    var levels = $("#ob_iDdlODropCursusItemsContainer .ob_iDdlICBC").find("li").not(":first").each(function () {
                                                                                                   var tmpLvl = {};
                                                                                                   tmpLvl.id = i;
                                                                                                   tmpLvl.name = $(this).find("b").first()[0].innerHTML;
                                                                                                   tmpLvl.value = $(this).find("i").first()[0].innerHTML;
                                                                                                   parsedLevels.push(tmpLvl);
                                                                                                   i++;
    });
    
    return parsedLevels;
}

iBoosterToolkit.selectMarkLevel = function (id) {
    $("#ob_iDdlODropCursusItemsContainer .ob_iDdlICBC").find("li")[id].onclick();
    return {};
}

iBoosterToolkit.parseMarks = function () {
    //console.time("counter");
    var spinWheelContainer = document.getElementById("ctl00_ContentPlaceHolder1_Lab1_upMain");
    if(spinWheelContainer.getAttribute("aria-hidden") == "false")
    {
        //Not loaded yet
        return {"error": true, "loading": true};
    }
    var marksContainer = $("#ctl00_ContentPlaceHolder1_Lab1_ctl01_fstMain");
    if(marksContainer.length == 0) {
        return {"error": true};
    }
    var parsedLevels = iBoosterToolkit.parseMarksLevels();
    marksContainer = null;
    var marks = [];
    var tables = $("#ctl00_ContentPlaceHolder1_Lab1_ctl01_fstMain").find("table").not(":first").each(function () {
        marks.push(iBoosterToolkit.parseMarkTable($(this)));
    });
    //console.timeEnd("counter");
    //Meme si on a qu'un tableau, cela permet de parser tres facilement de l'autre coté ...
    return {"subjects" : marks, "levels" : parsedLevels};
}

iBoosterToolkit.parseMarkTable = function (table) {
    var parsedTable = {};
    //On enleve le span pour recup le nom de la matiere, mais on recup ce span en meme temps !
    //Le parsing est destructeur, je sais.
    var subjectInfo = table.find("tr td span").eq(0).remove()[0].innerHTML;
    parsedTable.title = table.find("tr td")[0].innerHTML.replace(/(&nbsp;)*/g,"");
    parsedTable.code = subjectInfo.substring(1,6);
    parsedTable.credits = subjectInfo.match(/:[0-9]+\)/g)[0].replace(/\)/g, "").replace(/:/g, "");

    parsedTable.validated = (subjectInfo.indexOf('√') != -1);

    subjectInfo = null;

    parsedTable.marks = [];
    table.find("tr td div").each(function () {
        var parsedMark = {};
        parsedMark.mark = $(this).find("span").remove()[0].innerText;
        if(parsedMark.mark == "Absence") {
            parsedMark.mark = -1;
        }
        parsedMark.name = $(this)[0].innerText.replace(/\n/g,"");
        parsedTable.marks.push(parsedMark);
    });

    return parsedTable;
}

iBoosterToolkit.getPlanningFormBody = function() {
    $("#__EVENTTARGET").val("ctl00$ContentPlaceHolder1$LnkIcs");
    return {"body" : $('#aspnetForm').serialize()};
}

iBoosterToolkit.parseSummary = function (table) {
    var marksContainer = $("#ctl00_ContentPlaceHolder1_Lab1_ctl01_fstMain");
    if(marksContainer.length == 0) {
        return {"error": true};
    }
    marksContainer = null;
    var summaries = [];
    var summaryRawRows = $("#ctl00_ContentPlaceHolder1_Lab1_ctl01_fstMain").find("table").not(":first").find("tr");
    var summaryRows = [];
    for (var i = 1; i < (summaryRawRows.length - 3); i++) {
        var tmp = summaryRawRows.eq(i).find("td");
        var parsedSummary = {};
        parsedSummary.title = tmp[0].innerText;
        parsedSummary.percentage = tmp[4].innerText;
        tmp = tmp[2].innerText.match(/[0-9]+/g);
        parsedSummary.mark = tmp[0];
        parsedSummary.markTheory = tmp[1];
        summaryRows.push(parsedSummary);
    };
    return {"summaries" : summaryRows};
}