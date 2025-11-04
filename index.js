const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static('public'));

let cart = [];
let orders = [];

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/api/menu', (req, res) => {
  const menuItems = [
    {
      id: 1,
      name: 'Margherita Pizza',
      category: 'Pizza',
      price: 12.99,
      description: 'Classic tomato sauce, mozzarella, and basil',
      image: '🍕'
    },
    {
      id: 2,
      name: 'Cheeseburger',
      category: 'Burgers',
      price: 9.99,
      description: 'Beef patty with cheese, lettuce, and tomato',
      image: '🍔'
    },
    {
      id: 3,
      name: 'Caesar Salad',
      category: 'Salads',
      price: 8.99,
      description: 'Romaine lettuce with Caesar dressing and croutons',
      image: '🥗'
    },
    {
      id: 4,
      name: 'Pepperoni Pizza',
      category: 'Pizza',
      price: 14.99,
      description: 'Tomato sauce, mozzarella, and pepperoni',
      image: '🍕'
    },
    {
      id: 5,
      name: 'Pasta Carbonara',
      category: 'Pasta',
      price: 13.99,
      description: 'Creamy pasta with bacon and parmesan',
      image: '🍝'
    },
    {
      id: 6,
      name: 'Chicken Wings',
      category: 'Appetizers',
      price: 10.99,
      description: 'Spicy buffalo wings with ranch dressing',
      image: '🍗'
    }
  ];
  res.json(menuItems);
});

app.post('/api/cart', (req, res) => {
  const { item } = req.body;
  cart.push(item);
  res.json({ success: true, cart });
});

app.get('/api/cart', (req, res) => {
  res.json(cart);
});

app.delete('/api/cart', (req, res) => {
  cart = [];
  res.json({ success: true });
});

app.post('/api/orders', (req, res) => {
  const { customerName, items, total } = req.body;
  const order = {
    id: orders.length + 1,
    customerName,
    items,
    total,
    status: 'pending',
    timestamp: new Date().toISOString()
  };
  orders.push(order);
  cart = [];
  res.json({ success: true, order });
});

app.get('/api/orders', (req, res) => {
  res.json(orders);
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Restaurant Store App running on http://localhost:${PORT}`);
  console.log(`✅ Server started successfully!`);
});
