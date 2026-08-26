package rules;

import model.GlobalMetrics;

public class TemperatureRule extends Rule {

    public TemperatureRule(String operador, double valorLimite) {
        super(operador, valorLimite);
    }

    @Override
    public boolean evaluar(GlobalMetrics metrica) {
        return comparar(metrica.getMaxTemperature());
    }

    @Override
    public String getTipoAlerta() {
        return "TEMP_ALTA";
    }
}