// A dummy app coz i need database for it to work but database is only for 7 days trial

import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/time;

import wso2/choreo.sendemail as ChoreoEmail;

// Configurable URL for the Taskify API
configurable string todoListApiUrl = ?;

// Define the type for a TodoItem
type TodoItem record {
    int id;
    string task;
    string deadline;
};

public function main() returns error? {
    io:println("Taskify API URL: " + todoListApiUrl);
    http:Client todoListApiEndpoint = check new (todoListApiUrl);

    // Fetching the Taskify items
    TodoItem[] todoList = check todoListApiEndpoint->/get_todo_list();

    foreach TodoItem item in todoList {
        // Sending an email reminder for each todo item
        check sendEmailReminder(item);
    }
}

function sendEmailReminder(TodoItem item) returns error? {

    // Format the deadline date
    string formattedDeadline = check formatDate(item.deadline);

    // Appending branding details to the content
    string finalContent = string `
Dear User,

This is a friendly reminder that you have a task to "${item.task}" due by ${formattedDeadline}.

Thank you for using our Taskify app. We hope it helps you stay organized and productive!

Best regards,
The Taskify Team
`;

    // Sending the email reminder
    ChoreoEmail:Client emailClient = check new ();
    string sendEmailResponse = check emailClient->sendEmail("recipient@example.com", "Taskify Task Reminder", finalContent);
    log:printInfo("Email sent successfully to: recipient@example.com with response: " + sendEmailResponse);
}

function formatDate(string deadline) returns string|error {
    // Parse the deadline date and format it
    time:Time formattedTime = check time:parse(deadline, "yyyy-MM-dd");
    string formattedDate = check formattedTime.format("MMMM dd, yyyy");

    return formattedDate;
}
