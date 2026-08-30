package rules;

import model.GlobalMetrics;

/**
 * Clase abstracta que representa una regla de alerta generica del
 * mini-lenguaje definido en docs/contracts.md (gramatica: identificador,
 * operador, numero). Cada subclase concreta sabe extraer y evaluar
 * una metrica distinta de {@link GlobalMetrics}.
 * <p>
 * Esta jerarquia es la base del polimorfismo del proyecto: el codigo
 * que recorre una lista de reglas nunca necesita saber de que subclase
 * concreta es cada una, solo llama a {@link #evaluar(GlobalMetrics)}.
 */
public abstract class Rule {

    /** Operador de comparacion de la regla ({@code >}, {@code <}, {@code >=}, {@code <=}). */
    protected String operador;

    /** Valor numerico contra el que se compara la metrica. */
    protected double valorLimite;

    /**
     * Construye una regla con su operador y valor limite.
     *
     * @param operador texto del operador de comparacion
     * @param valorLimite valor numerico limite de la regla
     */
    public Rule(String operador, double valorLimite) {
        this.operador = operador;
        this.valorLimite = valorLimite;
    }

    /**
     * Evalua si esta regla se dispara para las metricas dadas.
     * Cada subclase decide contra que metrica especifica comparar.
     *
     * @param metrica las metricas globales ya calculadas por Fortran
     * @return true si la condicion de la regla se cumple
     */
    public abstract boolean evaluar(GlobalMetrics metrica);

    /**
     * Identifica el tipo de alerta que produce esta regla al dispararse.
     *
     * @return el identificador del tipo de alerta (ej. "TEMP_ALTA"),
     *         tal como se escribe en alerts.csv
     */
    public abstract String getTipoAlerta();

    /**
     * Compara un valor real contra el limite de la regla, usando el
     * operador definido. Logica compartida por todas las subclases,
     * para no repetir el switch en cada una.
     *
     * @param valorReal el valor de la metrica ya extraido por la subclase
     * @return true si la comparacion se cumple segun el operador
     * @throws IllegalArgumentException si el operador no es uno de
     *         los 4 reconocidos por la gramatica ({@code >}, {@code <},
     *         {@code >=}, {@code <=})
     */
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