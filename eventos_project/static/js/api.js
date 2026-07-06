// Helper compartilhado por todas as páginas para consumir a API REST.
// Centraliza fetch + tratamento de erro para não repetir código em cada tela.

const API_BASE = "/api";

async function apiRequest(path, options = {}) {
    const response = await fetch(`${API_BASE}${path}`, {
        headers: { "Content-Type": "application/json" },
        ...options,
    });

    let data = null;
    try {
        data = await response.json();
    } catch (e) {
        data = null;
    }

    if (!response.ok) {
        const mensagem = (data && data.erro) || `Erro na requisição (HTTP ${response.status}).`;
        throw new Error(mensagem);
    }

    return data;
}

function apiGet(path) {
    return apiRequest(path, { method: "GET" });
}

function apiPost(path, body) {
    return apiRequest(path, { method: "POST", body: JSON.stringify(body) });
}

function apiPut(path, body) {
    return apiRequest(path, { method: "PUT", body: JSON.stringify(body) });
}

function apiDelete(path, body) {
    const options = { method: "DELETE" };
    if (body) options.body = JSON.stringify(body);
    return apiRequest(path, options);
}

// Exibe uma mensagem de sucesso/erro numa caixinha no topo do formulário/página
function mostrarMensagem(elementId, texto, tipo = "sucesso") {
    const el = document.getElementById(elementId);
    if (!el) return;
    el.textContent = texto;
    el.className = `alerta alerta-${tipo}`;
    el.style.display = "block";
    setTimeout(() => {
        el.style.display = "none";
    }, 4000);
}
