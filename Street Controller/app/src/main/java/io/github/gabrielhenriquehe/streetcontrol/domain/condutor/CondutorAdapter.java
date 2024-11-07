package io.github.gabrielhenriquehe.streetcontrol.domain.condutor;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

import io.github.gabrielhenriquehe.streetcontrol.R;

public class CondutorAdapter extends RecyclerView.Adapter<CondutorViewHolder> {

    Context context;
    List<Condutor> condutores;

    public CondutorAdapter(Context context, List<Condutor> condutores) {
        this.context = context;
        this.condutores = condutores;
    }

    @NonNull
    @Override
    public CondutorViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new CondutorViewHolder(LayoutInflater.from(context).inflate(R.layout.view_condutores_list_item, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull CondutorViewHolder holder, int position) {
        holder.nameView.setText(condutores.get(position).getNome());
    }

    @Override
    public int getItemCount() {
        return condutores.size();
    }
}
