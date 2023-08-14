var socket

function connect()
{
	socket = new WebSocket(getBaseURL() + "/ws");
	socket.onmessage = function(message) {	
        var toast = JSON.parse(message.data);

        var toastBody = toast.message;
        var bgColor = "#209cee";
        switch (toast.status) {
            case "Error":
                bgColor = "#ff3860";
                break;
            case "Success":
                bgColor = "#23d160";
                break;
        }

        Toastify({
            className: "toast-" + toast.status,
            text: toastBody,
            style: {
                background: bgColor
            }
        }).showToast();
    }
}

function getBaseURL()
{   
    const re = new RegExp("^https?://")
	var href = window.location.href.replace(re, "");
	var idx = href.indexOf("/");
	return "ws://" + href.substring(0, idx);
}

connect();