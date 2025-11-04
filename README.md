# Restaurant Store App

A web-based restaurant ordering application that allows customers to browse menus, add items to cart, and place orders online.

## ✅ Implementation Status

This is a **fully functional** Node.js/Express web application with a complete frontend interface.

### Features Implemented

- ✅ **Express Backend Server**: RESTful API with all core endpoints
- ✅ **Menu Management**: Browse restaurant menu with categories and prices
- ✅ **Shopping Cart**: Add/remove items, view cart total
- ✅ **Order Placement**: Complete checkout flow with order confirmation
- ✅ **Responsive UI**: Modern, mobile-friendly interface
- ✅ **Real-time Updates**: Dynamic cart updates and order tracking
- ✅ **Health Check Endpoint**: Monitor server status

## API Endpoints

The server provides the following REST endpoints:

- `GET /` - Main application interface
- `GET /health` - Health check endpoint
- `GET /api/menu` - Get all menu items
- `GET /api/cart` - Get current cart items
- `POST /api/cart` - Add item to cart
- `DELETE /api/cart` - Clear cart
- `POST /api/orders` - Place a new order
- `GET /api/orders` - Get all orders

## Menu Items

The app features a variety of food items including:

- 🍕 Pizzas (Margherita, Pepperoni)
- 🍔 Burgers (Cheeseburger)
- 🥗 Salads (Caesar Salad)
- 🍝 Pasta (Carbonara)
- 🍗 Appetizers (Chicken Wings)

## Getting Started

### Prerequisites

- Node.js 14.0 or higher
- npm or yarn package manager

### Installation

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Start the Server**
   ```bash
   npm start
   ```

3. **Access the Application**
   
   Open your browser and navigate to:
   ```
   http://localhost:3000
   ```

### Testing

The server includes a health check endpoint:
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "timestamp": "2025-11-04T13:28:29.564Z"
}
```

Test the menu API:
```bash
curl http://localhost:3000/api/menu
```

## Project Structure

```
restaurant-store-app/
├── index.js           # Express server with API endpoints
├── package.json       # Project dependencies and scripts
├── public/            # Static files
│   └── index.html     # Frontend application
├── .gitignore         # Git ignore rules
└── README.md          # This file
```

## Technology Stack

### Backend
- **Express.js**: Fast, minimalist web framework
- **Node.js**: JavaScript runtime

### Frontend
- **HTML5**: Modern semantic markup
- **CSS3**: Responsive design with gradients and animations
- **JavaScript (ES6+)**: Dynamic functionality with Fetch API

## Features

### 🛒 Shopping Experience
- Browse menu items by category
- View detailed item descriptions and prices
- Add items to cart with one click
- Real-time cart updates with item count
- View cart total before checkout

### 📦 Order Management
- Simple checkout process
- Order confirmation with order ID
- Order history tracking
- Customer name association with orders

### 🎨 User Interface
- Modern, gradient-based design
- Smooth animations and transitions
- Responsive layout for mobile and desktop
- Intuitive navigation
- Visual feedback for user actions

## Running the Application

The application runs on port 3000 by default. You can change this by setting the PORT environment variable:

```bash
PORT=8080 npm start
```

## Development

### Adding Menu Items

Edit the `menuItems` array in `index.js`:

```javascript
const menuItems = [
  {
    id: 1,
    name: 'Item Name',
    category: 'Category',
    price: 9.99,
    description: 'Item description',
    image: '🍔'
  }
];
```

### Customizing Styles

The styles are embedded in `/public/index.html`. Look for the `<style>` section to customize colors, fonts, and layouts.

## API Examples

### Get Menu
```bash
curl http://localhost:3000/api/menu
```

### Add to Cart
```bash
curl -X POST http://localhost:3000/api/cart \
  -H "Content-Type: application/json" \
  -d '{"item": {"id": 1, "name": "Pizza", "price": 12.99}}'
```

### Place Order
```bash
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "customerName": "John Doe",
    "items": [{"id": 1, "name": "Pizza", "price": 12.99}],
    "total": 12.99
  }'
```

## License

MIT

## Contributing

Feel free to submit issues and enhancement requests!

---

**Status**: ✅ **Application is fully functional and ready to use!**

The app successfully starts on `http://localhost:3000` and all features are working without errors.
