// Engine genérico de CRUD (listar / cadastrar / editar / excluir).
// Reaproveitado por Evento, Palestra, Palestrante e Patrocinador — entidades
// que possuem os 5 endpoints REST completos no backend.
//
// config = {
//   listEndpoint: '/eventos/',
//   createEndpoint: '/eventos/',
//   updateEndpoint: (id) => `/eventos/${id}`,
//   deleteEndpoint: (id) => `/eventos/${id}`,
//   columns: [{ key: 'id', label: 'ID' }, { key: 'nome', label: 'Nome' }, ...],
//   fields: [{ name: 'nome', label: 'Nome', type: 'text', required: true }, ...],
// }

function initCrudPage(config) {
    const tabelaBody = document.getElementById("tabela-body");
    const form = document.getElementById("form-registro");
    const formTitulo = document.getElementById("form-titulo");
    const btnCancelar = document.getElementById("btn-cancelar-edicao");
    let idEmEdicao = null;

    function renderFormFields() {
        form.innerHTML = "";
        config.fields.forEach((campo) => {
            const label = document.createElement("label");
            label.textContent = campo.label;
            label.setAttribute("for", `campo-${campo.name}`);
            form.appendChild(label);

            const input =
                campo.type === "textarea" ? document.createElement("textarea") : document.createElement("input");
            if (campo.type !== "textarea") input.type = campo.type || "text";
            input.id = `campo-${campo.name}`;
            input.name = campo.name;
            if (campo.required) input.required = true;
            if (campo.step) input.step = campo.step;
            form.appendChild(input);
        });
    }

    function preencherFormulario(registro) {
        config.fields.forEach((campo) => {
            const input = document.getElementById(`campo-${campo.name}`);
            if (input) input.value = registro[campo.name] ?? "";
        });
    }

    function limparFormulario() {
        form.reset();
        idEmEdicao = null;
        formTitulo.textContent = "Cadastrar novo";
        btnCancelar.style.display = "none";
    }

    function renderTabela(registros) {
        tabelaBody.innerHTML = "";
        registros.forEach((registro) => {
            const tr = document.createElement("tr");
            config.columns.forEach((coluna) => {
                const td = document.createElement("td");
                td.textContent = registro[coluna.key] ?? "";
                tr.appendChild(td);
            });

            const tdAcoes = document.createElement("td");

            const btnEditar = document.createElement("button");
            btnEditar.textContent = "Editar";
            btnEditar.className = "btn-editar";
            btnEditar.onclick = () => {
                idEmEdicao = registro.id;
                formTitulo.textContent = `Editando #${registro.id}`;
                btnCancelar.style.display = "inline-block";
                preencherFormulario(registro);
                window.scrollTo({ top: 0, behavior: "smooth" });
            };
            tdAcoes.appendChild(btnEditar);

            const btnExcluir = document.createElement("button");
            btnExcluir.textContent = "Excluir";
            btnExcluir.className = "btn-perigo";
            btnExcluir.onclick = async () => {
                if (!confirm("Confirma a exclusão deste registro?")) return;
                try {
                    await apiDelete(config.deleteEndpoint(registro.id));
                    mostrarMensagem("mensagem", "Registro excluído com sucesso.", "sucesso");
                    carregarLista();
                } catch (erro) {
                    mostrarMensagem("mensagem", erro.message, "erro");
                }
            };
            tdAcoes.appendChild(btnExcluir);

            tr.appendChild(tdAcoes);
            tabelaBody.appendChild(tr);
        });
    }

    async function carregarLista() {
        try {
            const registros = await apiGet(config.listEndpoint);
            renderTabela(registros);
        } catch (erro) {
            mostrarMensagem("mensagem", erro.message, "erro");
        }
    }

    form.addEventListener("submit", async (evento) => {
        evento.preventDefault();
        const dados = {};
        config.fields.forEach((campo) => {
            const input = document.getElementById(`campo-${campo.name}`);
            dados[campo.name] = campo.type === "number" ? Number(input.value) : input.value;
        });

        try {
            if (idEmEdicao) {
                await apiPut(config.updateEndpoint(idEmEdicao), dados);
                mostrarMensagem("mensagem", "Registro atualizado com sucesso.", "sucesso");
            } else {
                await apiPost(config.createEndpoint, dados);
                mostrarMensagem("mensagem", "Registro criado com sucesso.", "sucesso");
            }
            limparFormulario();
            carregarLista();
        } catch (erro) {
            mostrarMensagem("mensagem", erro.message, "erro");
        }
    });

    btnCancelar.addEventListener("click", limparFormulario);

    renderFormFields();
    carregarLista();
}
