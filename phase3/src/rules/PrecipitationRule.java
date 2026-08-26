package rules;

import model.GlobalMetrics;

public class PrecipitationRule extends Rule {

    public PrecipitationRule(String operador, double valorLimite) {
        super(operador, valorLimite);
    }

    @Override
    public boolean evaluar(GlobalMetrics metrica) {
        return comparar(metrica.getTotalPrecipitation());
    }

    @Override
    public String getTipoAlerta() {
        return "LLUVIA_INTENSA";
    }
}