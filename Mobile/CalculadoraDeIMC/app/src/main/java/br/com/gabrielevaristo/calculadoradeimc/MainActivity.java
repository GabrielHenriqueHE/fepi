package br.com.gabrielevaristo.calculadoradeimc;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import java.util.Formatter;

public class MainActivity extends AppCompatActivity {

    private EditText userInputHeight, userInputWeight;
    private TextView labelForIMCResult, IMCResult, IMCSituation;
    private Button btnFnCalculateIMC;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);

        this.userInputHeight = findViewById(R.id.userInputHeight);
        this.userInputWeight = findViewById(R.id.userInputWeight);
        this.labelForIMCResult = findViewById(R.id.labelForIMCResult);
        this.IMCResult = findViewById(R.id.textIMCResult);
        this.IMCSituation = findViewById(R.id.textIMCSituation);
        this.btnFnCalculateIMC = findViewById(R.id.btnFnCalculateIMC);

        this.btnFnCalculateIMC.setOnClickListener(new View.OnClickListener() {
            @SuppressLint("SetTextI18n")
            @Override
            public void onClick(View view) {
                String inputHeight = userInputHeight.getText().toString();
                double height = Double.parseDouble(inputHeight);

                String inputWeight = userInputWeight.getText().toString();
                double weight = Double.parseDouble(inputWeight);

                try {
                    double IMC = weight / Math.pow(height, 2);
                    String IMCDescription;

                    if (IMC < 18.5) {
                        IMCDescription = "Abaixo do peso normal";
                    } else if (IMC >= 18.5 && IMC < 25) {
                        IMCDescription = "Peso normal";
                    } else if (IMC >= 25 && IMC < 30) {
                        IMCDescription = "Excesso de peso";
                    } else if (IMC >= 30 && IMC < 35) {
                        IMCDescription = "Obesidade classe I";
                    } else if (IMC >= 35 && IMC < 40) {
                        IMCDescription = "Obesidade classe II";
                    } else {
                        IMCDescription = "Obesidade classe III";
                    }

                    String resultToString = String.valueOf(IMC);
                    String integerPart = resultToString.split("\\.")[0];
                    String decimalPart = resultToString.substring(resultToString.indexOf(".") + 1, resultToString.indexOf(".") + 3);

                    String formattedResult = integerPart.concat(".").concat(decimalPart);
                    IMCResult.setText(formattedResult);
                    IMCSituation.setText(IMCDescription);

                    labelForIMCResult.setVisibility(View.VISIBLE);
                    IMCResult.setVisibility(View.VISIBLE);
                    IMCSituation.setVisibility(View.VISIBLE);
                } catch (Exception e) {
                    System.out.println(e.getStackTrace());
                }
            }
        });

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }
}