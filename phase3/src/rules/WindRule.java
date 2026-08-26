package rules;

import model.GlobalMetrics;

public class WindRule extends Rule {

    public WindRule(String operador, double valorLimite) {
        super(operador, valorLimite);
    }

    @Override
    public boolean evaluar(GlobalMetrics metrica) {
        return comparar(metrica.getMaxWindSpeed());
    }

    @Override
    public String getTipoAlerta() {
        return "VIENTO_FUERTE";
    }
}