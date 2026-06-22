import 'order.dart';
import 'notification.dart';
import 'transaction.dart';

final List<DriverOrder> mockDriverOrders = [
  DriverOrder(
    id: '#8492',
    customerName: 'Sarah Jenkins',
    customerRating: 5.0,
    pickupName: 'The Golden Skillet',
    pickupAddress: '124 Culinary Blvd',
    dropoffAddress: '892 Skyline Apt (Leave at door)',
    distance: '4.2 mi',
    estTime: '15 min',
    estPayout: 8.0,
    status: 'available',
    deliveryNotes: 'Please don\'t ring the doorbell, baby is sleeping. Leave it on the rocking chair. Thanks!',
    items: [
      OrderItem(name: 'Truffle Burger Meal', quantity: 2),
      OrderItem(name: 'Artisan Fries', quantity: 1),
    ],
  ),
  DriverOrder(
    id: '#1234',
    customerName: 'John Doe',
    customerRating: 4.7,
    pickupName: 'Luigi\'s Trattoria',
    pickupAddress: '123 Main St.',
    dropoffAddress: '456 Elm St, Apt 4B',
    distance: '2.4 mi',
    estTime: '10 min',
    estPayout: 12.5,
    status: 'available',
    items: [
      OrderItem(name: 'Margherita Pizza', quantity: 1),
      OrderItem(name: 'Garlic Bread', quantity: 1),
    ],
  ),
  DriverOrder(
    id: '#4092',
    customerName: 'Michael R.',
    customerRating: 4.9,
    pickupName: 'Sushi Zen',
    pickupAddress: '789 Pine Ave',
    dropoffAddress: '12 Ocean Drive, Unit 3A',
    distance: '3.1 mi',
    estTime: '18 min',
    estPayout: 14.25,
    status: 'available',
    items: [
      OrderItem(name: 'Spicy Tuna Roll', quantity: 2),
      OrderItem(name: 'Miso Soup', quantity: 2),
    ],
  ),
  DriverOrder(
    id: '#1052',
    customerName: 'Emily S.',
    customerRating: 5.0,
    pickupName: 'Coffee Hub',
    pickupAddress: 'Downtown Square',
    dropoffAddress: 'Tech Tower, Floor 14',
    distance: '1.2 mi',
    estTime: '8 min',
    estPayout: 6.50,
    status: 'available',
    items: [
      OrderItem(name: 'Large Iced Latte', quantity: 1),
      OrderItem(name: 'Blueberry Muffin', quantity: 1),
    ],
  ),
];

final List<DriverNotification> mockDriverNotifications = [
  DriverNotification(
    id: '1',
    icon: 'local_pizza',
    title: 'New High-Paying Order',
    body: '\$15.50 payout for 2.1 miles. Luigi\'s Trattoria. Accept now?',
    time: '2m ago',
    type: 'order',
    orderRef: '#1234',
  ),
  DriverNotification(
    id: '2',
    icon: 'star',
    title: 'Bonus Activated!',
    body: 'Earn an extra \$3 on every delivery in the Downtown zone for the next 2 hours.',
    time: '15m ago',
    read: true,
    type: 'alert',
  ),
];

final List<DriverTransaction> mockDriverTransactions = [
  DriverTransaction(
    id: 'tx1',
    type: 'delivery',
    title: 'Delivery - Order #9021',
    subtitle: 'Today, 1:45 PM',
    amount: 12.50,
    completed: true,
  ),
  DriverTransaction(
    id: 'tx2',
    type: 'bonus',
    title: 'Lunch Rush Bonus',
    subtitle: 'Today, 1:00 PM',
    amount: 5.00,
    completed: true,
  ),
  DriverTransaction(
    id: 'tx3',
    type: 'delivery',
    title: 'Delivery - Order #9012',
    subtitle: 'Yesterday, 8:15 PM',
    amount: 14.25,
    completed: true,
  ),
  DriverTransaction(
    id: 'tx4',
    type: 'payout',
    title: 'Weekly Payout Initiated',
    subtitle: 'Yesterday, 9:00 AM',
    amount: -450.00,
    completed: true,
  ),
];
