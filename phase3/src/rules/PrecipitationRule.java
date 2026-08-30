package rules;

import model.GlobalMetrics;

/**
 * Regla que evalua la precipitacion acumulada total (identificador
 * LLUVIA_INTENSA en rules.txt).
 */
public class PrecipitationRule extends Rule {

    /**
     * Construye la regla de lluvia intensa.
     *
     * @param operador operador de comparacion (ej. {@code >})
     * @param valorLimite umbral de precipitacion acumulada en milimetros
     */
    public PrecipitationRule(String operador, double valorLimite) {
        super(operador, valorLimite);
    }

    /**
     * @param metrica las metricas globales calculadas por Fortran
     * @return true si la precipitacion total cumple la comparacion definida
     */
    @Override
    public boolean evaluar(GlobalMetrics metrica) {
        return comparar(metrica.getTotalPrecipitation());
    }

    /** @return siempre "LLUVIA_INTENSA" */
    @Override
    public String getTipoAlerta() {
        return "LLUVIA_INTENSA";
    }
}