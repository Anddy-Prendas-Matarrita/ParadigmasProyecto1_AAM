package rules;

import model.GlobalMetrics;

/**
 * Regla que evalua la velocidad de viento maxima registrada
 * (identificador VIENTO_FUERTE en rules.txt).
 */
public class WindRule extends Rule {

    /**
     * Construye la regla de viento fuerte.
     *
     * @param operador operador de comparacion (ej. {@code >})
     * @param valorLimite umbral de velocidad de viento en km/h
     */
    public WindRule(String operador, double valorLimite) {
        super(operador, valorLimite);
    }

    /**
     * @param metrica las metricas globales calculadas por Fortran
     * @return true si el viento maximo cumple la comparacion definida
     */
    @Override
    public boolean evaluar(GlobalMetrics metrica) {
        return comparar(metrica.getMaxWindSpeed());
    }

    /** @return siempre "VIENTO_FUERTE" */
    @Override
    public String getTipoAlerta() {
        return "VIENTO_FUERTE";
    }
}