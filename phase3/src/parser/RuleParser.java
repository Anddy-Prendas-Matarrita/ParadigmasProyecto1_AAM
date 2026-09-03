package parser;

import rules.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Lee el archivo de reglas llamado rules.txt y construye los objetos Rule
 * correspondientes, validando que cada linea cumpla la gramatica:
 * {@code <regla> ::= <identificador> <operador> <numero>}
 */
public class RuleParser {

    /**
     * Crea un nuevo parser de reglas, sin estado inicial que configurar.
     */
    public RuleParser() {
    }

    /**
     * Parsea el archivo de reglas completo.
     *
     * @param rutaArchivo ruta al archivo rules.txt
     * @return lista de objetos Rule ya construidos
     * @throws IOException si el archivo no existe o no se puede leer
     */
    public List<Rule> parsearArchivo(String rutaArchivo) throws IOException {
        List<Rule> reglas = new ArrayList<>();

        try (BufferedReader br = new BufferedReader(new FileReader(rutaArchivo))) {
            String linea;
            while ((linea = br.readLine()) != null) {
                linea = linea.trim();
                if (linea.isEmpty()) continue;

                Rule regla = parsearLinea(linea);
                if (regla != null) {
                    reglas.add(regla);
                } else {
                }
            }
        }
        return reglas;
    }

    /**
     * Parsea una sola linea de texto y construye el objeto Rule correspondiente.
     *
     * @param linea texto como "TEMP_ALTA > 35"
     * @return el objeto Rule construido, o null si la linea no es valida
     */
    public Rule parsearLinea(String linea) {
        String[] tokens = linea.split("\\s+");

        if (tokens.length != 3) {
            return null;
        }

        String identificador = tokens[0];
        String operador = tokens[1];
        String textoNumero = tokens[2];

        if (!esOperadorValido(operador)) {
            return null;
        }

        double valorLimite;
        try {
            valorLimite = Double.parseDouble(textoNumero);
        } catch (NumberFormatException e) {
            return null;
        }

        switch (identificador) {
            case "TEMP_ALTA":
                return new TemperatureRule(operador, valorLimite);
            case "LLUVIA_INTENSA":
                return new PrecipitationRule(operador, valorLimite);
            case "VIENTO_FUERTE":
                return new WindRule(operador, valorLimite);
            case "BATERIA_BAJA":
                return new BatteryRule(operador, valorLimite);
            default:
                return null;
        }
    }

    /**
     * Verifica si un texto corresponde a uno de los operadores permitidos
     * por la gramatica del mini-lenguaje ({@code >}, {@code <}, {@code >=}, {@code <=}).
     *
     * @param operador texto a validar
     * @return true si es un operador reconocido
     */
    private boolean esOperadorValido(String operador) {
        return operador.equals(">") || operador.equals("<")
            || operador.equals(">=") || operador.equals("<=");
    }
}