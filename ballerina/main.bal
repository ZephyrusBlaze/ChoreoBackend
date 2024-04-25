import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/time;

import wso2/choreo.sendemail as ChoreoEmail;

configurable string todoApiUrl = ?;

type TodoItem record {
    string task;
    string deadline;
};

public function main() returns error? {
    io:println("Todo API URL: " + todoApiUrl);
    http:Client todoApiEndpoint = check new (todoApiUrl);

    // Fetching the todo items
    TodoItem[] todoItems = check todoApiEndpoint->/todos;

    foreach TodoItem todoItem in todoItems {
        // Sending an email reminder
        check sendEmail(todoItem);
    }
}

function sendEmail(TodoItem todoItem) returns error? {

    // Format the deadline
    string formattedDeadline = check getFormattedDeadline(todoItem.deadline);

    // Appending branding details to the content
    string finalContent = string `
Dear User,

This is a friendly reminder that you have a task "${todoItem.task}" due on ${formattedDeadline}.

Thank you for using our Todo List app. We hope it helps you stay organized and productive.

Best regards,
The Todo List Team

---

Todo List - Stay Organized, Stay Productive

Website: https://www.todolistapp.com
Support: support@todolistapp.com
Phone: +1 (800) 123-4567

Connect with us:
- Facebook: https://www.facebook.com/TodoListApp
- Twitter: https://twitter.com/TodoListApp

Privacy Policy | Terms of Service | Unsubscribe

This message is intended only for the recipient and may contain confidential information. If you are not the intended recipient, please disregard this message.
`;

    ChoreoEmail:Client emailClient = check new ();
    string sendEmailResponse = check emailClient->sendEmail("user@example.com", "Todo Task Reminder", finalContent);
    log:printInfo("Email sent successfully to user@example.com with response: " + sendEmailResponse);
}

function getFormattedDeadline(string deadline) returns string|error {
    time:Utc utcTime = check time:utcFromString(deadline);

    // Convert UTC time to IST
    time:TimeZone istZone = check new ("Asia/Kolkata");
    time:Civil istTime = istZone.utcToCivil(utcTime);

    // Format the IST time
    string formattedDeadline = check time:civilToEmailString(istTime, time:PREFER_TIME_ABBREV);
    return formattedDeadline;
}
