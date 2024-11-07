package io.github.gabrielhenriquehe.streetcontrol.domain.condutor;

import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import io.github.gabrielhenriquehe.streetcontrol.R;

public class CondutorViewHolder extends RecyclerView.ViewHolder {

    TextView nameView;

    public CondutorViewHolder(@NonNull View itemView) {
        super(itemView);
        nameView = itemView.findViewById(R.id.name);
    }
}
