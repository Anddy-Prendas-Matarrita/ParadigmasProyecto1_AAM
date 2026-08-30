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

    /**
     * Construye el objeto con las 7 metricas ya calculadas.
     *
     * @param totalPrecipitation precipitacion acumulada total (mm)
     * @param averageTemperature temperatura promedio (°C)
     * @param maxTemperature temperatura maxima registrada (°C)
     * @param minTemperature temperatura minima registrada (°C)
     * @param averageWindSpeed velocidad de viento promedio (km/h)
     * @param maxWindSpeed velocidad de viento maxima registrada (km/h)
     * @param averageBatteryLevel nivel de bateria promedio (%)
     */
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

    /**
     * Precipitacion acumulada total.
     * @return el valor en milimetros
     */
    public double getTotalPrecipitation() { return totalPrecipitation; }

    /**
     * Temperatura promedio del conjunto de datos.
     * @return el valor en grados Celsius
     */
    public double getAverageTemperature() { return averageTemperature; }

    /**
     * Temperatura maxima registrada.
     * @return el valor en grados Celsius
     */
    public double getMaxTemperature() { return maxTemperature; }

    /**
     * Temperatura minima registrada.
     * @return el valor en grados Celsius
     */
    public double getMinTemperature() { return minTemperature; }

    /**
     * Velocidad de viento promedio.
     * @return el valor en km/h
     */
    public double getAverageWindSpeed() { return averageWindSpeed; }

    /**
     * Velocidad de viento maxima registrada.
     * @return el valor en km/h
     */
    public double getMaxWindSpeed() { return maxWindSpeed; }

    /**
     * Nivel de bateria promedio.
     * @return el valor como porcentaje
     */
    public double getAverageBatteryLevel() { return averageBatteryLevel; }
}