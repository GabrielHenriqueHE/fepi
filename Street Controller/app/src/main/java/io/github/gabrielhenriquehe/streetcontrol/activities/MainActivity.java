package io.github.gabrielhenriquehe.streetcontrol.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.FragmentTransaction;

import io.github.gabrielhenriquehe.streetcontrol.R;
import io.github.gabrielhenriquehe.streetcontrol.domain.condutor.CondutoresFragment;
import io.github.gabrielhenriquehe.streetcontrol.fragments.InitialFragment;
import io.github.gabrielhenriquehe.streetcontrol.fragments.VeiculosFragment;

public class MainActivity extends AppCompatActivity {

    private CondutoresFragment condutoresFragment;
    private VeiculosFragment veiculosFragment;
    private InitialFragment initialFragment;
    private Button btnCallCondutores, btnCallVeiculos, btnBack;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);

        btnCallCondutores = findViewById(R.id.btnCallCondutores);
        btnCallVeiculos = findViewById(R.id.btnCallVeiculos);
        btnBack = findViewById(R.id.btnBack);

        condutoresFragment = new CondutoresFragment();
        veiculosFragment = new VeiculosFragment();
        initialFragment = new InitialFragment();

        FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
        transaction.add(R.id.renderFrame, initialFragment);
        transaction.commit();

        btnCallCondutores.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
                transaction.replace(R.id.renderFrame, condutoresFragment);
                transaction.commit();
            }
        });

        btnCallVeiculos.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
                transaction.replace(R.id.renderFrame, veiculosFragment);
                transaction.commit();
            }
        });

        btnBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
                transaction.replace(R.id.renderFrame, initialFragment);
                transaction.commit();
            }
        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }
}