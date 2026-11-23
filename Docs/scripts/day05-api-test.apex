
Http http = new Http();
HttpRequest request = new HttpRequest();

request.setEndpoint(
    'callout:NovaHome_JSONPlaceholder/users/1'
);
request.setMethod('GET');
request.setHeader('Accept', 'application/json');

try {
    HttpResponse response = http.send(request);

    System.debug('HTTP Status: ' + response.getStatusCode());
    System.debug('Response Body: ' + response.getBody());

    if (response.getStatusCode() == 200) {
        Map<String, Object> userData =
            (Map<String, Object>) JSON.deserializeUntyped(
                response.getBody()
            );

        System.debug('User ID: ' + userData.get('id'));
        System.debug('Name: ' + userData.get('name'));
        System.debug('Email: ' + userData.get('email'));
        System.debug('Company: ' +
            ((Map<String, Object>) userData.get('company')).get('name'));
    }
} catch (Exception e) {
    System.debug('Callout Error: ' + e.getMessage());
}
