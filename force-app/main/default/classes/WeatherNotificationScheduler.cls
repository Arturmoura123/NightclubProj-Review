public class WeatherNotificationScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        WeatherNotificationService.sendWeatherAlerts();
    }
}
