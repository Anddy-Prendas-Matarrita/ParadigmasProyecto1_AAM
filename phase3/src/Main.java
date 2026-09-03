import model.GlobalMetrics;
import parser.RuleParser;
import rules.Rule;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Punto de entrada de la Etapa 3 (Java) del pipeline PolyFlow.
 * Lee las metricas globales generadas por Fortran (metrics.csv) y el
 * archivo de reglas (rules.txt), evalua cada regla mediante polimorfismo,
 * y escribe las alertas resultantes en alerts.csv para la Etapa 4 (MIPS).
 */
public class Main {

    /**
     * Orquesta la lectura de metricas, el parseo de reglas, la evaluacion
     * y la escritura del archivo de alertas.
     *
     * @param args no se utilizan argumentos de linea de comandos
     */
    public static void main(String[] args) {
        String rutaMetrics = "data/middle/metrics.csv";
        String rutaReglas = "phase3/rules.txt";
        String rutaAlertas = "data/middle/alerts.csv";

        try {
            GlobalMetrics metricas = leerMetrics(rutaMetrics);
            System.out.println("Metricas leidas correctamente.");

            RuleParser parser = new RuleParser();
            List<Rule> reglas = parser.parsearArchivo(rutaReglas);

            List<String> alertasGeneradas = evaluarReglas(metricas, reglas);
            escribirAlertas(rutaAlertas, alertasGeneradas);

            System.out.println("Alertas generadas ");

        } catch (IOException e) {
            System.out.println("Error al procesar los archivos: " + e.getMessage());
            System.exit(1);
        }
    }

    /**
     * Lee metrics.csv en formato clave-valor (Metric,Value) y construye
     * un objeto GlobalMetrics con los datos ya convertidos a numero.
     *
     * @param ruta ruta al archivo metrics.csv
     * @return objeto GlobalMetrics con las 7 metricas cargadas
     * @throws IOException si el archivo no existe o no se puede leer
     */
    private static GlobalMetrics leerMetrics(String ruta) throws IOException {
        Map<String, Double> valores = new HashMap<>();

        try (BufferedReader br = new BufferedReader(new FileReader(ruta))) {
            String linea = br.readLine();

            while ((linea = br.readLine()) != null) {
                if (linea.trim().isEmpty()) continue;

                String[] campos = linea.split(",");
                String clave = campos[0].trim();
                double valor = Double.parseDouble(campos[1].trim());
                valores.put(clave, valor);
            }
        }

        return new GlobalMetrics(
            valores.get("Total_Precipitation"),
            valores.get("Average_Temperature"),
            valores.get("Max_Temperature"),
            valores.get("Min_Temperature"),
            valores.get("Average_Wind_Speed"),
            valores.get("Max_Wind_Speed"),
            valores.get("Average_Battery_Level")
        );
    }

    /**
     * Evalua todas las reglas contra las metricas globales.
     * Aqui ocurre el polimorfismo: regla.evaluar(metricas) actua distinto
     * segun la subclase real de cada Rule, sin que este metodo lo sepa.
     *
     * @param metricas las metricas globales calculadas por Fortran
     * @param reglas lista de reglas ya parseadas desde rules.txt
     * @return lista de tipos de alerta que se dispararon
     */
    private static List<String> evaluarReglas(GlobalMetrics metricas, List<Rule> reglas) {
        List<String> alertas = new java.util.ArrayList<>();

        for (Rule regla : reglas) {
            if (regla.evaluar(metricas)) {
                alertas.add(regla.getTipoAlerta());
            }
        }
        return alertas;
    }

    /**
     * Escribe alerts.csv con las alertas generadas, en el formato
     * de una sola columna TIPO_ALERTA definido en contracts.md.
     *
     * @param ruta ruta donde se debe escribir alerts.csv
     * @param alertas lista de tipos de alerta a escribir
     * @throws IOException si el archivo no se puede crear o escribir
     */
    private static void escribirAlertas(String ruta, List<String> alertas) throws IOException {
        try (FileWriter fw = new FileWriter(ruta)) {
            fw.write("TIPO_ALERTA\n");
            for (String alerta : alertas) {
                fw.write(alerta + "\n");
            }
        }
    }
}