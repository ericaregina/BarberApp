require('dotenv').config();
const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = 5100;

const connection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME
});

connection.connect((err) => {
    if (err) throw err;
    console.log("Conectado ao banco de dados!");
});

module.exports = connection;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Rota de cadastro
app.post('/register', (req, res) => {
    const { email, password } = req.body;

    // Verifica se o usuário já existe
    db.query('SELECT * FROM users WHERE email = ?', [email], async (err, result) => {
        if (result.length > 0) {
            return res.status(400).json({ message: 'Usuário já cadastrado!' });
        }

        // Criptografa a senha
        const hashedPassword = await bcrypt.hash(password, 10);

        // Insere no banco de dados
        db.query('INSERT INTO users (email, password) VALUES (?, ?)', [email, hashedPassword], (err, result) => {
            if (err) {
                return res.status(500).json({ message: 'Erro ao cadastrar usuário!' });
            }
            res.status(201).json({ message: 'Usuário cadastrado com sucesso!' });
        });
    });
});

// Rota de login
app.post('/login', (req, res) => {
    const { email, password } = req.body;

    db.query('SELECT * FROM users WHERE email = ?', [email], async (err, result) => {
        if (result.length === 0) {
            return res.status(401).json({ message: 'Usuário não encontrado!' });
        }

        const user = result[0];
        const isPasswordValid = await bcrypt.compare(password, user.password);

        if (!isPasswordValid) {
            return res.status(401).json({ message: 'Senha incorreta!' });
        }

        // Gera um token JWT
        const token = jwt.sign({ id: user.id, email: user.email }, 'secreto123', { expiresIn: '1h' });

        res.status(200).json({ message: 'Login realizado com sucesso!', token });
    });
});

// Rota de recuperação de senha (simples, apenas simula envio)
app.post('/recover-password', (req, res) => {
    const { email } = req.body;

    db.query('SELECT * FROM users WHERE email = ?', [email], (err, result) => {
        if (result.length === 0) {
            return res.status(404).json({ message: 'Usuário não encontrado!' });
        }

        // Simula o envio de um link de recuperação
        res.json({ message: 'E-mail de recuperação enviado! Verifique sua caixa de entrada.' });
    });
});

// Inicia o servidor
app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});
