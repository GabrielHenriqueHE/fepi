package io.github.gabrielhenriquehe.streetcontrol.domain.condutor;

import java.time.LocalDate;
import java.util.Date;
import java.util.Objects;

public class Condutor {
    private String cpf;
    private String nome;
    private Date nascimento;
    private Date cadastro;

    public Condutor(String cpf, String nome, Date nascimento, Date cadastro) {
        this.cpf = cpf;
        this.nome = nome;
        this.nascimento = nascimento;
        this.cadastro = cadastro;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public Date getNascimento() {
        return nascimento;
    }

    public void setNascimento(Date nascimento) {
        this.nascimento = nascimento;
    }

    public Date getCadastro() {
        return cadastro;
    }

    public void setCadastro(Date cadastro) {
        this.cadastro = cadastro;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Condutor condutor = (Condutor) o;
        return Objects.equals(cpf, condutor.cpf);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(cpf);
    }
}
