package model;

/**
 * Representa las metricas globales calculadas por Fortran (metrics.csv),
 * en formato clave-valor.
 */
public class GlobalMetrics {
    private double totalPrecipitation;
    private double averageTemperature;
    private double maxTemperature;
    private double minTemperature;
    private double averageWindSpeed;
    private double maxWindSpeed;
    private double averageBatteryLevel;

    public GlobalMetrics(double totalPrecipitation, double averageTemperature, double maxTemperature,
                          double minTemperature, double averageWindSpeed, double maxWindSpeed,
                          double averageBatteryLevel) {
        this.totalPrecipitation = totalPrecipitation;
        this.averageTemperature = averageTemperature;
        this.maxTemperature = maxTemperature;
        this.minTemperature = minTemperature;
        this.averageWindSpeed = averageWindSpeed;
        this.maxWindSpeed = maxWindSpeed;
        this.averageBatteryLevel = averageBatteryLevel;
    }

    public double getTotalPrecipitation() { return totalPrecipitation; }
    public double getAverageTemperature() { return averageTemperature; }
    public double getMaxTemperature() { return maxTemperature; }
    public double getMinTemperature() { return minTemperature; }
    public double getAverageWindSpeed() { return averageWindSpeed; }
    public double getMaxWindSpeed() { return maxWindSpeed; }
    public double getAverageBatteryLevel() { return averageBatteryLevel; }
}