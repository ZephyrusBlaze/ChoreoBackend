import wso2/choreo.sendemail as ChoreoEmail;

type Appointment record {
    string name;
    string email;
};

function main() returns error? {
    // Creating appointment records
    Appointment[] appointments = [
        {name: "John Doe", email: "john@example.com"},
        {name: "Jane Smith", email: "jane@example.com"}
    ];

    // Sending emails for each appointment
    foreach Appointment appointment in appointments {
        // Sending an email to the patient
        check sendEmail(appointment);
    }
}

function sendEmail(Appointment appointment) returns error? {
    // Email content
    string finalContent = string `
Dear ${appointment.name},

Thanks for using taskify!

We encourage you to add and complete tasks on taskify. This will help you to track your progress!

Warm regards,
Taskify Team
`;

    // Sending email using Choreo Email Client
    ChoreoEmail:Client emailClient = check new ();
    string sendEmailResponse = check emailClient->sendEmail(appointment.email, "Upcoming Appointment Reminder", finalContent);
    io:println("Email sent successfully to: " + appointment.email + " with response: " + sendEmailResponse);
}
