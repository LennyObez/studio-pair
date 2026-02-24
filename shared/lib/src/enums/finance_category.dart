import 'package:json_annotation/json_annotation.dart';

/// Main finance category.
@JsonEnum(valueField: 'value')
enum FinanceCategory {
  @JsonValue('housing')
  housing('housing', 'Housing'),

  @JsonValue('utilities')
  utilities('utilities', 'Utilities'),

  @JsonValue('food')
  food('food', 'Food'),

  @JsonValue('transport')
  transport('transport', 'Transport'),

  @JsonValue('health')
  health('health', 'Health'),

  @JsonValue('children')
  children('children', 'Children'),

  @JsonValue('pets')
  pets('pets', 'Pets'),

  @JsonValue('personal')
  personal('personal', 'Personal'),

  @JsonValue('entertainment')
  entertainment('entertainment', 'Entertainment'),

  @JsonValue('education')
  education('education', 'Education'),

  @JsonValue('savings')
  savings('savings', 'Savings'),

  @JsonValue('debt')
  debt('debt', 'Debt'),

  @JsonValue('insurance')
  insurance('insurance', 'Insurance'),

  @JsonValue('gifts_and_donations')
  giftsAndDonations('gifts_and_donations', 'Gifts & Donations'),

  @JsonValue('taxes')
  taxes('taxes', 'Taxes'),

  @JsonValue('other')
  other('other', 'Other');

  const FinanceCategory(this.value, this.label);

  final String value;
  final String label;

  /// Returns the list of subcategories for this category.
  List<FinanceSubcategory> get subcategories {
    return FinanceSubcategory.values
        .where((sub) => sub.parentCategory == this)
        .toList();
  }
}

/// Finance subcategory, linked to a parent [FinanceCategory].
@JsonEnum(valueField: 'value')
enum FinanceSubcategory {
  // Housing
  @JsonValue('rent')
  rent('rent', 'Rent', FinanceCategory.housing),
  @JsonValue('mortgage')
  mortgage('mortgage', 'Mortgage', FinanceCategory.housing),
  @JsonValue('property_tax')
  propertyTax('property_tax', 'Property Tax', FinanceCategory.housing),
  @JsonValue('housing_insurance')
  housingInsurance('housing_insurance', 'Insurance', FinanceCategory.housing),
  @JsonValue('maintenance')
  maintenance('maintenance', 'Maintenance', FinanceCategory.housing),

  // Utilities
  @JsonValue('electricity')
  electricity('electricity', 'Electricity', FinanceCategory.utilities),
  @JsonValue('water')
  water('water', 'Water', FinanceCategory.utilities),
  @JsonValue('gas')
  gas('gas', 'Gas', FinanceCategory.utilities),
  @JsonValue('internet')
  internet('internet', 'Internet', FinanceCategory.utilities),
  @JsonValue('phone')
  phone('phone', 'Phone', FinanceCategory.utilities),
  @JsonValue('streaming')
  streaming('streaming', 'Streaming', FinanceCategory.utilities),

  // Food
  @JsonValue('groceries')
  groceries('groceries', 'Groceries', FinanceCategory.food),
  @JsonValue('dining_out')
  diningOut('dining_out', 'Dining Out', FinanceCategory.food),
  @JsonValue('coffee')
  coffee('coffee', 'Coffee', FinanceCategory.food),
  @JsonValue('delivery')
  delivery('delivery', 'Delivery', FinanceCategory.food),

  // Transport
  @JsonValue('car_payment')
  carPayment('car_payment', 'Car Payment', FinanceCategory.transport),
  @JsonValue('car_insurance')
  carInsurance('car_insurance', 'Car Insurance', FinanceCategory.transport),
  @JsonValue('fuel')
  fuel('fuel', 'Fuel', FinanceCategory.transport),
  @JsonValue('public_transport')
  publicTransport(
    'public_transport',
    'Public Transport',
    FinanceCategory.transport,
  ),
  @JsonValue('parking')
  parking('parking', 'Parking', FinanceCategory.transport),
  @JsonValue('tolls')
  tolls('tolls', 'Tolls', FinanceCategory.transport),
  @JsonValue('transport_maintenance')
  transportMaintenance(
    'transport_maintenance',
    'Maintenance',
    FinanceCategory.transport,
  ),

  // Health
  @JsonValue('health_insurance')
  healthInsurance('health_insurance', 'Insurance', FinanceCategory.health),
  @JsonValue('doctor')
  doctor('doctor', 'Doctor', FinanceCategory.health),
  @JsonValue('medication')
  medication('medication', 'Medication', FinanceCategory.health),
  @JsonValue('dental')
  dental('dental', 'Dental', FinanceCategory.health),
  @JsonValue('optical')
  optical('optical', 'Optical', FinanceCategory.health),
  @JsonValue('gym')
  gym('gym', 'Gym', FinanceCategory.health),

  // Children
  @JsonValue('childcare')
  childcare('childcare', 'Childcare', FinanceCategory.children),
  @JsonValue('school_supplies')
  schoolSupplies(
    'school_supplies',
    'School Supplies',
    FinanceCategory.children,
  ),
  @JsonValue('extracurricular')
  extracurricular(
    'extracurricular',
    'Extracurricular',
    FinanceCategory.children,
  ),
  @JsonValue('children_clothing')
  childrenClothing('children_clothing', 'Clothing', FinanceCategory.children),

  // Pets
  @JsonValue('pet_food')
  petFood('pet_food', 'Food', FinanceCategory.pets),
  @JsonValue('veterinary')
  veterinary('veterinary', 'Veterinary', FinanceCategory.pets),
  @JsonValue('pet_insurance')
  petInsurance('pet_insurance', 'Insurance', FinanceCategory.pets),
  @JsonValue('grooming')
  grooming('grooming', 'Grooming', FinanceCategory.pets),

  // Personal
  @JsonValue('clothing')
  clothing('clothing', 'Clothing', FinanceCategory.personal),
  @JsonValue('haircare')
  haircare('haircare', 'Haircare', FinanceCategory.personal),
  @JsonValue('personal_care')
  personalCare('personal_care', 'Personal Care', FinanceCategory.personal),

  // Entertainment
  @JsonValue('subscriptions')
  subscriptions(
    'subscriptions',
    'Subscriptions',
    FinanceCategory.entertainment,
  ),
  @JsonValue('games')
  games('games', 'Games', FinanceCategory.entertainment),
  @JsonValue('hobbies')
  hobbies('hobbies', 'Hobbies', FinanceCategory.entertainment),
  @JsonValue('events')
  events('events', 'Events', FinanceCategory.entertainment),
  @JsonValue('books')
  books('books', 'Books', FinanceCategory.entertainment),

  // Education
  @JsonValue('tuition')
  tuition('tuition', 'Tuition', FinanceCategory.education),
  @JsonValue('courses')
  courses('courses', 'Courses', FinanceCategory.education),
  @JsonValue('materials')
  materials('materials', 'Materials', FinanceCategory.education),

  // Savings
  @JsonValue('emergency')
  emergency('emergency', 'Emergency', FinanceCategory.savings),
  @JsonValue('retirement')
  retirement('retirement', 'Retirement', FinanceCategory.savings),
  @JsonValue('investment')
  investment('investment', 'Investment', FinanceCategory.savings),

  // Debt
  @JsonValue('loan_repayment')
  loanRepayment('loan_repayment', 'Loan Repayment', FinanceCategory.debt),
  @JsonValue('credit_card')
  creditCard('credit_card', 'Credit Card', FinanceCategory.debt),

  // Insurance
  @JsonValue('life_insurance')
  lifeInsurance('life_insurance', 'Life', FinanceCategory.insurance),
  @JsonValue('travel_insurance')
  travelInsurance('travel_insurance', 'Travel', FinanceCategory.insurance),

  // Gifts & Donations
  @JsonValue('gifts')
  gifts('gifts', 'Gifts', FinanceCategory.giftsAndDonations),
  @JsonValue('charity')
  charity('charity', 'Charity', FinanceCategory.giftsAndDonations),

  // Taxes
  @JsonValue('income_tax')
  incomeTax('income_tax', 'Income Tax', FinanceCategory.taxes),
  @JsonValue('other_taxes')
  otherTaxes('other_taxes', 'Other Taxes', FinanceCategory.taxes);

  const FinanceSubcategory(this.value, this.label, this.parentCategory);

  final String value;
  final String label;
  final FinanceCategory parentCategory;
}
