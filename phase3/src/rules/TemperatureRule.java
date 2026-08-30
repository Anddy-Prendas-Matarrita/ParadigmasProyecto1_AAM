package rules;

import model.GlobalMetrics;

/**
 * Regla que evalua la temperatura maxima registrada (identificador
 * TEMP_ALTA en rules.txt).
 */
public class TemperatureRule extends Rule {

    /**
     * Construye la regla de temperatura alta.
     *
     * @param operador operador de comparacion (ej. {@code >})
     * @param valorLimite umbral de temperatura en grados Celsius
     */
    public TemperatureRule(String operador, double valorLimite) {
        super(operador, valorLimite);
    }

    /**
     * @param metrica las metricas globales calculadas por Fortran
     * @return true si la temperatura maxima cumple la comparacion definida
     */
    @Override
    public boolean evaluar(GlobalMetrics metrica) {
        return comparar(metrica.getMaxTemperature());
    }

    /** @return siempre "TEMP_ALTA" */
    @Override
    public String getTipoAlerta() {
        return "TEMP_ALTA";
    }
}