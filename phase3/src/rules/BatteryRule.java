package rules;

import model.GlobalMetrics;

public class BatteryRule extends Rule {

    public BatteryRule(String operador, double valorLimite) {
        super(operador, valorLimite);
    }

    @Override
    public boolean evaluar(GlobalMetrics metrica) {
        return comparar(metrica.getAverageBatteryLevel());
    }

    @Override
    public String getTipoAlerta() {
        return "BATERIA_BAJA";
    }
}