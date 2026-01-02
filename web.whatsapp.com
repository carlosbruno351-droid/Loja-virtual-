import {
  BrowserRouter as Router,
  Routes,
  Route,
  Link,
  useParams,
} from "react-router-dom";
import { useState, useContext, createContext } from "react";

/* ================= CONTEXTO DO CARRINHO ================= */
const CartContext = createContext();

function CartProvider({ children }) {
  const [cart, setCart] = useState([]);

  function addToCart(prod) {
    setCart((prev) => [...prev, prod]);
  }

  function removeFromCart(index) {
    setCart(cart.filter((_, i) => i !== index));
  }

  return (
    <CartContext.Provider value={{ cart, addToCart, removeFromCart }}>
      {children}
    </CartContext.Provider>
  );
}

/* ================= NAVBAR ================= */
function Navbar() {
  const { cart } = useContext(CartContext);

  return (
    <nav style={{ padding: 15, background: "#fff", marginBottom: 20 }}>
      <strong>Loja Virtual</strong>{" "}
      <Link to="/">Home</Link> |{" "}
      <Link to="/categorias">Categorias</Link> |{" "}
      <Link to="/carrinho">Carrinho ({cart.length})</Link> |{" "}
      <Link to="/admin">Admin</Link>
    </nav>
  );
}

/* ================= HOME ================= */
function Home() {
  const produtos = [
    { id: 1, nome: "Kit Beleza Premium", preco: 79.9 },
    { id: 2, nome: "Organizador Multiuso", preco: 29.9 },
    { id: 3, nome: "Camiseta Unissex", preco: 49.9 },
    { id: 4, nome: "Jogo de Panelas", preco: 199.9 },
  ];

  return (
    <div style={{ padding: 20 }}>
      <h2>Produtos em Destaque</h2>
      {produtos.map((p) => (
        <div key={p.id}>
          <Link to={`/produto/${p.id}`}>
            {p.nome} - R$ {p.preco}
          </Link>
        </div>
      ))}
    </div>
  );
}

/* ================= CATEGORIAS ================= */
const categorias = [
  { id: 1, nome: "Beleza" },
  { id: 2, nome: "Utilidades" },
  { id: 3, nome: "Roupas" },
  { id: 4, nome: "Casa" },
];

function Categorias() {
  return (
    <div style={{ padding: 20 }}>
      <h2>Categorias</h2>
      {categorias.map((c) => (
        <div key={c.id}>
          <Link to={`/categoria/${c.id}`}>{c.nome}</Link>
        </div>
      ))}
    </div>
  );
}

/* ================= PRODUTOS ================= */
const produtosCategoria = {
  1: [{ id: 101, nome: "Creme Facial", preco: 39.9 }],
  2: [{ id: 201, nome: "Garrafa Térmica", preco: 29.9 }],
  3: [{ id: 301, nome: "Camiseta Oversized", preco: 49.9 }],
  4: [{ id: 401, nome: "Jogo de Toalhas", preco: 79.9 }],
};

function Categoria() {
  const { id } = useParams();
  const itens = produtosCategoria[id] || [];

  return (
    <div style={{ padding: 20 }}>
      <h2>Produtos</h2>
      {itens.map((p) => (
        <div key={p.id}>
          <Link to={`/produto/${p.id}`}>
            {p.nome} - R$ {p.preco}
          </Link>
        </div>
      ))}
    </div>
  );
}

function Produto() {
  const { id } = useParams();
  const { addToCart } = useContext(CartContext);

  const item = Object.values(produtosCategoria)
    .flat()
    .find((p) => p.id == id);

  if (!item) return <p>Produto não encontrado</p>;

  return (
    <div style={{ padding: 20 }}>
      <h2>{item.nome}</h2>
      <p>R$ {item.preco}</p>
      <button onClick={() => addToCart(item)}>Adicionar ao carrinho</button>
    </div>
  );
}

/* ================= CARRINHO ================= */
function Carrinho() {
  const { cart, removeFromCart } = useContext(CartContext);

  return (
    <div style={{ padding: 20 }}>
      <h2>Carrinho</h2>
      {cart.length === 0 && <p>Vazio</p>}
      {cart.map((item, i) => (
        <div key={i}>
          {item.nome} - R$ {item.preco}
          <button onClick={() => removeFromCart(i)}>X</button>
        </div>
      ))}
    </div>
  );
}

/* ================= ADMIN ================= */
function Admin() {
  return (
    <div style={{ padding: 20 }}>
      <h2>Painel Admin</h2>
      <p>Área administrativa (futura)</p>
    </div>
  );
}

/* ================= APP ================= */
export default function App() {
  return (
    <Router>
      <CartProvider>
        <Navbar />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/categorias" element={<Categorias />} />
          <Route path="/categoria/:id" element={<Categoria />} />
          <Route path="/produto/:id" element={<Produto />} />
          <Route path="/carrinho" element={<Carrinho />} />
          <Route path="/admin" element={<Admin />} />
        </Routes>
      </CartProvider>
    </Router>
  );
}
