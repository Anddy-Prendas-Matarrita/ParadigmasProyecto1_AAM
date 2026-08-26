package rules;

import model.GlobalMetrics;

public abstract class Rule {
    protected String operador;
    protected double valorLimite;

    public Rule(String operador, double valorLimite) {
        this.operador = operador;
        this.valorLimite = valorLimite;
    }

    public abstract boolean evaluar(GlobalMetrics metrica);

    public abstract String getTipoAlerta();

    protected boolean comparar(double valorReal) {
        switch (operador) {
            case ">":  return valorReal > valorLimite;
            case "<":  return valorReal < valorLimite;
            case ">=": return valorReal >= valorLimite;
            case "<=": return valorReal <= valorLimite;
            default:
                throw new IllegalArgumentException("Operador no reconocido: " + operador);
        }
    }
}