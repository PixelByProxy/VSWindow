(function () {
    "use strict";
    
    var applicationData = Windows.Storage.ApplicationData.current;
    var localSettings = applicationData.localSettings;
    var activeConn = null;

    var page = WinJS.UI.Pages.define("/pages/navbar/navbar.html", {
        ready: function (element, options) {
            //document.getElementById('cmd').addEventListener("click", showConnectionDialog, false);
            document.getElementById('connectionAddButton').addEventListener("click", addConnection, false);
            //document.getElementById('scenarioHideButtons').addEventListener("click", doHideItems, false);
            //document.getElementById('cmdAdd').addEventListener("click", doClickAdd, false);
            //document.getElementById('cmdRemove').addEventListener("click", doClickRemove, false);
            //document.getElementById('cmdDelete').addEventListener("click", doClickDelete, false);
            //document.getElementById('cmdCamera').addEventListener("click", doClickCamera, false);
            //WinJS.log && WinJS.log("To show the bar, press the Show Bar button, swipe up from the bottom of the screen, right-click, or press Windows Logo + z. To dismiss the bar, swipe, right-click, or press Windows Logo + z again.", "sample", "status");
            //// Set the default state of scenario buttons 
            //document.getElementById('scenarioShowButtons').disabled = true;
            //document.getElementById('scenarioHideButtons').disabled = true;
            //// Set the default state of all the AppBar 
            //document.getElementById('commandsAppBar').winControl.sticky = true;
            //// Listen for the AppBar events and enable and disable the buttons if the bar is shown or hidden 
            //document.getElementById('commandsAppBar').winControl.addEventListener("aftershow", scenarioBarShown, false);
            //document.getElementById('commandsAppBar').winControl.addEventListener("beforehide", scenarioBarHidden, false);

            var conns = getConns();
            for (var i in conns) {
                addConnButton(conns[i].id, conns[i].serverName, conns[i].serverPort);
            }

            socket.addOnOpened(onConnectionOpened);
            socket.addOnClosed(onConnectionClosed);
            socket.addOnFailed(onConnectionClosed);

        }
    });

    // Command button functions 
    function showConnectionDialog() {
        var formatTextButton = document.getElementById("cmd");
        document.getElementById("connectionFlyout").winControl.show(formatTextButton);
    }

    function addConnection() {
        
        var serverName = document.getElementById("serverName");
        var serverPort = document.getElementById("serverPort");
        var id = makeid();

        var conns = getConns();
        conns.push({ id:id, serverName: serverName.value, serverPort: serverPort.value });
        setConns(conns);

        addConnButton(id, serverName.value, serverPort.value);
        
        //Windows.UI.Popups.MessageDialog(conns.length).showAsync().then();

        serverName.value = "";
        serverPort.value = "";
        
        document.getElementById("connectionFlyout").winControl.hide();

    }

    function getConns() {
        var conns = localSettings.values["connections"];
        if (conns != null)
            conns = JSON.parse(conns);
        else
            conns = [];

        return conns;
    }

    function setConns(conns) {
        localSettings.values["connections"] = JSON.stringify(conns);
    }

    function getConn(connId) {
        var conn = null;
        var conns = getConns();
        for (var i in conns) {
            if (conns[i].id == connId) {
                conn = conns[i];
                break;
            }
        }

        return conn;
    }
    
    function addConnButton(id, serverName, serverPort) {
        var connsBar = document.getElementById("appbarConnections");
        var btn = document.createElement("div");
        btn.style.position = "relative";
        btn.id = id;
        btn.className = "connButton";
        btn.innerHTML = serverName;
        btn.addEventListener("click", function () { connect(id); } , false);
        connsBar.appendChild(btn);
    }
    
    function connect(connId) {
        var conn = getConn(connId);
        if (conn) {
            
            activeConn = conn;

            hideBusy();

            // add the busy image
            var connDiv = document.getElementById(activeConn.id);
            var busyDiv = document.createElement("div");
            busyDiv.style.position = "absolute";
            busyDiv.style.height = "80px";
            busyDiv.style.width = "140px";
            busyDiv.style.left = "0";
            busyDiv.style.top = "0";
            busyDiv.style.backgroundColor = "rgba(255, 255, 255, 0.8)";
            busyDiv.id = "connectProgress";
            busyDiv.addEventListener("click", function (e) { e.stopPropagation(); });

            var busyIcon = document.createElement("progress");
            busyIcon.className = "win-ring";
            busyIcon.style.position = "absolute";
            busyIcon.style.height = "40px";
            busyIcon.style.width = "40px";
            busyIcon.style.left = "50px";
            busyIcon.style.top = "10px";
            busyDiv.appendChild(busyIcon);

            var cancelButton = document.createElement("a");
            cancelButton.appendChild(document.createTextNode("Cancel"));
            cancelButton.style.fontWeight = "bold";
            cancelButton.style.position = "absolute";
            cancelButton.style.right = "5px";
            cancelButton.style.top = "55px";
            cancelButton.style.fontSize = "18px";
            cancelButton.href = "javascript:void(0);";
            cancelButton.addEventListener("click", function (e) { socket.close(); });
            busyDiv.appendChild(cancelButton);

            connDiv.appendChild(busyDiv);

            setTimeout(function() {
                socket.open(conn.serverName, conn.serverPort);
            }, 50);
        }
    }
    
    function makeid() {
        var text = "";
        var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        var nameExists = false;
        var conns = getConns();

        do {

            text = "";
            
            for (var i = 0; i < 5; i++)
                text += possible.charAt(Math.floor(Math.random() * possible.length));
            
            for (var conn in conns) {
                nameExists = text == conns[conn].id;
                if (nameExists)
                    break;
            }

        } while (nameExists)

        return text;
    }

    function onConnectionOpened() {

        hideBusy();

        var connDiv = document.getElementById(activeConn.id);
        connDiv.style.backgroundColor = "red";
    }

    function onConnectionClosed() {

        hideBusy();

        if (activeConn != null) {
            var connDiv = document.getElementById(activeConn.id);
            connDiv.style.backgroundColor = "transparent";
            activeConn = null;
        }
        
    }
    
    function hideBusy() {
        var busyDialog = document.getElementById("connectProgress");
        if (busyDialog != null)
            busyDialog.parentNode.removeChild(busyDialog);
    }

    function doClickAdd() {
        WinJS.log && WinJS.log("Add button pressed", "sample", "status");
    }

    function doClickRemove() {
        WinJS.log && WinJS.log("Remove button pressed", "sample", "status");
    }

    function doClickDelete() {
        WinJS.log && WinJS.log("Delete button pressed", "sample", "status");
    }

    function doClickCamera() {
        WinJS.log && WinJS.log("Camera button pressed", "sample", "status");
    }

    function doShowBar() {
        document.getElementById('commandsAppBar').winControl.show();
    }


    // These functions are used by the scenario to show and hide elements 
    function doShowItems() {
        document.getElementById('commandsAppBar').winControl.showCommands([cmdAdd, cmdRemove, appBarSeparator, cmdDelete]);
        document.getElementById('scenarioShowButtons').disabled = true;
        document.getElementById('scenarioHideButtons').disabled = false;
    }

    function doHideItems() {
        document.getElementById('commandsAppBar').winControl.hideCommands([cmdAdd, cmdRemove, appBarSeparator, cmdDelete]);
        document.getElementById('scenarioHideButtons').disabled = true;
        document.getElementById('scenarioShowButtons').disabled = false;
    }

    // These functions are used by the scenario to disable and enable the scenario buttons when the AppBar shows and hides 
    function scenarioBarShown() {
        document.getElementById('scenarioShowBar').disabled = true;
        if (document.getElementById('cmdAdd').style.visibility === "hidden") {
            document.getElementById('scenarioShowButtons').disabled = false;
        } else {
            document.getElementById('scenarioHideButtons').disabled = false;
        }
    }

    function scenarioBarHidden() {
        document.getElementById('scenarioShowBar').disabled = false;
        document.getElementById('scenarioShowButtons').disabled = true;
        document.getElementById('scenarioHideButtons').disabled = true;
    }

})();