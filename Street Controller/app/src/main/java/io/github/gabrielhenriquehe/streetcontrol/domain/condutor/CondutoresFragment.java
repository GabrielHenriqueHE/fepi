package io.github.gabrielhenriquehe.streetcontrol.domain.condutor;

import android.os.Bundle;

import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import io.github.gabrielhenriquehe.streetcontrol.R;

public class CondutoresFragment extends Fragment {

    public CondutoresFragment() {

    }

    public static CondutoresFragment newInstance() {
        return new CondutoresFragment();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(
            LayoutInflater inflater,
            ViewGroup container,
            Bundle savedInstanceState
    ) {
        View view = inflater.inflate(R.layout.fragment_condutores, container, false);

        RecyclerView recyclerView = view.findViewById(R.id.listCondutores);

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        try {
            CondutoresRepository.addCondutor(new Condutor("158.391.983-22", "Gabriel Henrique", sdf.parse("01/04/2024"), sdf.parse("07/11/2024")));
            CondutoresRepository.addCondutor(new Condutor("258.391.903-33", "Carlos Silva", sdf.parse("01/05/2024"), sdf.parse("07/12/2024")));
            CondutoresRepository.addCondutor(new Condutor("358.391.983-44", "Ana Souza", sdf.parse("01/06/2024"), sdf.parse("07/01/2025")));

        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
        List<Condutor> condutores = CondutoresRepository.getCondutores();

        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        CondutorAdapter adapter = new CondutorAdapter(getContext(), condutores);
        recyclerView.setAdapter(adapter);
        adapter.notifyDataSetChanged();



        return view;
    }
}