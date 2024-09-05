public with sharing class WeatherService {

    public static String getWeather(String city) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://c053f5ef-8d68-4d46-9027-5c422b235dc4.mock.pstmn.io/?q=' + city + '&appid=dummy-key2&units=metric');
        // req.setEndpoint('https://api.openweathermap.org/data/2.5/weather?q=' + city + '&appid=9bf630740096bd5a3411421fb7a449e8&units=metric');
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            throw new CalloutException('Failed to get weather data: ' + res.getStatus());
        }
    }

    public static Boolean isRainy(String weatherData) {
        Map<String, Object> weatherMap = (Map<String, Object>)JSON.deserializeUntyped(weatherData);
        List<Object> weatherList = (List<Object>) weatherMap.get('weather');
        Map<String, Object> firstWeather = (Map<String, Object>) weatherList.get(0);
        String mainWeather = (String) firstWeather.get('main');

        return mainWeather == 'Rain';
    }
}
