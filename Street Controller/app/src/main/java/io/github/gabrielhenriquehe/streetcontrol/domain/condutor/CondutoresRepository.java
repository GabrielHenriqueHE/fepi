package io.github.gabrielhenriquehe.streetcontrol.domain.condutor;

import java.util.ArrayList;
import java.util.List;

public class CondutoresRepository {
    public static List<Condutor> condutores = new ArrayList<>();

    public static List<Condutor> getCondutores() {
        return condutores;
    }

    public static void addCondutor(Condutor condutor) {
        condutores.add(condutor);
    }
}
