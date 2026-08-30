package rules;

import model.GlobalMetrics;

/**
 * Regla que evalua el nivel de bateria promedio (identificador
 * BATERIA_BAJA en rules.txt).
 */
public class BatteryRule extends Rule {

    /**
     * Construye la regla de bateria baja.
     *
     * @param operador operador de comparacion (ej. {@code <})
     * @param valorLimite umbral de porcentaje de bateria
     */
    public BatteryRule(String operador, double valorLimite) {
        super(operador, valorLimite);
    }

    /**
     * @param metrica las metricas globales calculadas por Fortran
     * @return true si la bateria promedio cumple la comparacion definida
     */
    @Override
    public boolean evaluar(GlobalMetrics metrica) {
        return comparar(metrica.getAverageBatteryLevel());
    }

    /** @return siempre "BATERIA_BAJA" */
    @Override
    public String getTipoAlerta() {
        return "BATERIA_BAJA";
    }
}