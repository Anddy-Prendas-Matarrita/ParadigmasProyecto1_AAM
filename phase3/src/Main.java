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

public class Main {

    public static void main(String[] args) {
        String rutaMetrics = "data/middle/metrics.csv";
        String rutaReglas = "phase3/rules.txt";
        String rutaAlertas = "data/middle/alerts.csv";
        System.out.println("Directorio de trabajo actual: " + System.getProperty("user.dir"));
        try {
            GlobalMetrics metricas = leerMetrics(rutaMetrics);
            System.out.println("Metricas leidas correctamente.");

            RuleParser parser = new RuleParser();
            List<Rule> reglas = parser.parsearArchivo(rutaReglas);
            System.out.println("Reglas cargadas: " + reglas.size());

            List<String> alertasGeneradas = evaluarReglas(metricas, reglas);
            escribirAlertas(rutaAlertas, alertasGeneradas);

            System.out.println("Alertas generadas: " + alertasGeneradas.size());
            System.out.println("Archivo alerts.csv escrito correctamente.");

        } catch (IOException e) {
            System.out.println("Error al procesar los archivos: " + e.getMessage());
        }
    }

    /**
     * Lee metrics.csv en formato clave-valor (Metric,Value) y construye
     * un objeto GlobalMetrics con los datos ya convertidos a numero.
     */
    private static GlobalMetrics leerMetrics(String ruta) throws IOException {
        Map<String, Double> valores = new HashMap<>();

        try (BufferedReader br = new BufferedReader(new FileReader(ruta))) {
            String linea = br.readLine();   // descartar encabezado "Metric,Value"

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
     * Polimorfismo: regla.evaluar(metricas) actua distinto segun la subclase real.
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
     * Escribe alerts.csv con las alertas generadas (sin columna ESTACION,
     * ya que las metricas son globales, no por estacion).
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