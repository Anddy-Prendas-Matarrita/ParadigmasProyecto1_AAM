package parser;

import rules.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Lee el archivo de reglas (rules.txt) y construye los objetos Rule
 * correspondientes, validando que cada linea cumpla la gramatica:
 * <regla> ::= <identificador> <operador> <numero>
 */
public class RuleParser {

    /**
     * Parsea el archivo de reglas completo.
     * @param rutaArchivo ruta al archivo rules.txt
     * @return lista de objetos Rule ya construidos
     */
    public List<Rule> parsearArchivo(String rutaArchivo) throws IOException {
        List<Rule> reglas = new ArrayList<>();

        try (BufferedReader br = new BufferedReader(new FileReader(rutaArchivo))) {
            String linea;
            while ((linea = br.readLine()) != null) {
                linea = linea.trim();
                if (linea.isEmpty()) continue;   // ignorar lineas en blanco

                Rule regla = parsearLinea(linea);
                if (regla != null) {
                    reglas.add(regla);
                } else {
                    System.out.println("Linea invalida ignorada: " + linea);
                }
            }
        }
        return reglas;
    }

    /**
     * Parsea una sola linea de texto y construye el objeto Rule correspondiente.
     * @param linea texto como "TEMP_ALTA > 35"
     * @return el objeto Rule construido, o null si la linea no es valida
     */
    public Rule parsearLinea(String linea) {
        String[] tokens = linea.split("\\s+");

        // validar la gramatica: debe tener exactamente 3 tokens
        if (tokens.length != 3) {
            return null;
        }

        String identificador = tokens[0];
        String operador = tokens[1];
        String textoNumero = tokens[2];

        // validar que el operador sea uno de los permitidos
        if (!esOperadorValido(operador)) {
            return null;
        }

        // validar que el tercer token sea realmente un numero
        double valorLimite;
        try {
            valorLimite = Double.parseDouble(textoNumero);
        } catch (NumberFormatException e) {
            return null;
        }

        // fabricar la subclase correcta segun el identificador
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
                return null;   // identificador no reconocido
        }
    }

    private boolean esOperadorValido(String operador) {
        return operador.equals(">") || operador.equals("<")
            || operador.equals(">=") || operador.equals("<=");
    }
}