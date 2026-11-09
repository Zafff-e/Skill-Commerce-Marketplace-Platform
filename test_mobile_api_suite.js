// Mobile App & Backend Contract Test Suite
// SkillCommerce / Dokkho Lok Khuji (দক্ষ লোক খুঁজি)

const http = require('http');

const API_BASE = 'http://localhost:5242';

function request(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, API_BASE);
    const options = {
      method: method,
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const parsed = data ? JSON.parse(data) : null;
          resolve({ status: res.statusCode, data: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, raw: data });
        }
      });
    });

    req.on('error', reject);
    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function runTests() {
  console.log('====================================================');
  console.log('🧪 Starting SkillCommerce Mobile App & API Test Suite');
  console.log('====================================================\n');

  let passed = 0;
  let failed = 0;

  function assert(condition, message) {
    if (condition) {
      console.log(`  ✅ PASS: ${message}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${message}`);
      failed++;
    }
  }

  try {
    // Test 1: Health & DB connectivity
    console.log('[1/7] Testing Health Readiness & Database Connection...');
    const health = await request('GET', '/health/ready');
    assert(health.status === 200, 'Health endpoint responds with HTTP 200');
    assert(health.data && health.data.database === 'Connected', 'Database is Connected in SkillCommerceDb');

    // Test 2: Taxonomy & 24 Categories with Bilingual Strings
    console.log('\n[2/7] Testing Categories & Bengali Taxonomy...');
    const catRes = await request('GET', '/api/v1/categories');
    assert(catRes.status === 200, 'Categories endpoint returns HTTP 200');
    assert(Array.isArray(catRes.data) && catRes.data.length >= 24, `Returned ${catRes.data.length} categories (expected >= 24)`);
    
    const acCat = catRes.data.find(c => c.categorySlug === 'electronics-appliances');
    assert(acCat !== undefined, 'Found Electronics & Appliances category');
    assert(acCat.categoryName.includes('ইলেকট্রনিক্স'), 'Category contains Bengali title');
    assert(acCat.skills.length >= 2, `Category has ${acCat.skills.length} nested skills`);

    // Test 3: Geo Provider Radar Matching
    console.log('\n[3/7] Testing Provider Geospatial Radius Discovery...');
    const provRes = await request('GET', '/api/v1/providers/search?lat=23.8103&lng=90.4125&radiusKm=20');
    assert(provRes.status === 200, 'Provider search returns HTTP 200');
    assert(Array.isArray(provRes.data) && provRes.data.length >= 2, `Discovered ${provRes.data.length} active providers`);

    const rafiqul = provRes.data.find(p => p.fullName.includes('Rafiqul'));
    assert(rafiqul !== undefined, 'Found Rafiqul Islam in radar');
    assert(rafiqul.verificationStatus === 'APPROVED', 'Provider is APPROVED');
    assert(typeof rafiqul.distanceKm === 'number', `Calculated distance: ${rafiqul.distanceKm} km`);

    // Test 4: Booking Creation & Financial Calculation
    console.log('\n[4/7] Testing Booking Creation & Isolated Financial Model...');
    const bookingPayload = {
      customerId: '44444444-4444-4444-4444-444444444444',
      providerId: rafiqul.profileId,
      skillId: 2, // Inverter AC Servicing (800 BDT)
      serviceAddress: 'Apartment 4B, Road 11, Gulshan-1, Dhaka',
      latitude: 23.7925,
      longitude: 90.4078,
      scheduledAt: new Date(Date.now() + 3600000).toISOString(),
      isEmergency: true, // +300 BDT urgency surcharge
      customerNotes: 'এসি থেকে ঠাণ্ডা বাতাস আসছে না। জরুরি ভিত্তিতে প্রয়োজন।'
    };

    const bookRes = await request('POST', '/api/v1/bookings', bookingPayload);
    assert(bookRes.status === 201, `Booking created successfully with HTTP 201 Created`);
    const booking = bookRes.data;
    assert(booking.referenceNumber.startsWith('BK-'), `Booking Reference generated: ${booking.referenceNumber}`);
    assert(booking.laborCost === 800, `Labor cost is 800 BDT`);
    assert(booking.emergencyFee === 300, `Urgency surcharge is 300 BDT`);
    assert(booking.commissionFee === 110, `Platform fee (10% of 1100) is 110 BDT`);
    assert(booking.totalAmount === 1100, `Initial total amount is 1100 BDT`);
    assert(booking.providerPayoutAmount === 990, `Provider payout (1100 - 110) is 990 BDT`);

    // Test 5: Ad-Hoc Spare Parts Billing (Strict 0% Platform Commission)
    console.log('\n[5/7] Testing Ad-Hoc Repair Parts Entry (0% Platform Fee)...');
    const partPayload = {
      partName: '45uF AC Inverter Dual Run Capacitor',
      partSku: 'CAP-AC-45UF',
      quantity: 1,
      unitPrice: 550.00
    };

    const partRes = await request('POST', `/api/v1/bookings/${booking.bookingId}/parts`, partPayload);
    assert(partRes.status === 200, 'Part added successfully with HTTP 200');
    assert(partRes.data.totalPrice === 550, 'Part line total is 550 BDT');

    const updatedBookingRes = await request('GET', `/api/v1/bookings/${booking.bookingId}`);
    const updated = updatedBookingRes.data;
    assert(updated.partsTotalCost === 550, `Materials amount updated to 550 BDT`);
    assert(updated.totalAmount === 1650, `Total bill increased to 1650 BDT (1100 + 550)`);
    assert(updated.commissionFee === 110, `Platform commission strictly remains 110 BDT (0% on parts)`);
    assert(updated.providerPayoutAmount === 1540, `Provider payout increased by 550 BDT to 1540 BDT (990 + 550)`);

    // Test 6: Lifecycle State Machine Steps
    console.log('\n[6/7] Testing Mobile Service Lifecycle State Machine...');
    const travelRes = await request('POST', `/api/v1/bookings/${booking.bookingId}/start-travel`);
    assert(travelRes.status === 200 && travelRes.data.status === 'EN_ROUTE', 'Transitioned to EN_ROUTE');

    const arriveRes = await request('POST', `/api/v1/bookings/${booking.bookingId}/arrive`);
    assert(arriveRes.status === 200 && arriveRes.data.status === 'ARRIVED', 'Transitioned to ARRIVED');

    const workRes = await request('POST', `/api/v1/bookings/${booking.bookingId}/start-work`);
    assert(workRes.status === 200 && workRes.data.status === 'IN_PROGRESS', 'Transitioned to IN_PROGRESS');

    const completeRes = await request('POST', `/api/v1/bookings/${booking.bookingId}/complete`);
    assert(completeRes.status === 200 && completeRes.data.status === 'COMPLETED', 'Transitioned to COMPLETED');

    // Phase 3 Requirement: Invalid Transition Rejection
    console.log('\n[6b/7] Testing Invalid State Machine Transition Rejection...');
    const invalidTransitionRes = await request('POST', `/api/v1/bookings/${booking.bookingId}/start-travel`);
    assert(invalidTransitionRes.status === 400, 'Invalid transition from COMPLETED to EN_ROUTE correctly rejected with HTTP 400');

    // Test 7: Authentication & Dual-Persona
    console.log('\n[7/7] Testing Dual-Persona Auth & JWT Token Issuance...');
    const authRes = await request('POST', '/api/v1/auth/login', {
      emailOrPhone: '+8801711223344',
      password: 'AnyPassword'
    });
    assert(authRes.status === 200, 'Provider login succeeded');
    assert(authRes.data.fullName.includes('Rafiqul'), `Authenticated as ${authRes.data.fullName}`);
    assert(authRes.data.profileId !== null, `Provider profile bound: ${authRes.data.profileId}`);
    assert(typeof authRes.data.token === 'string' && authRes.data.token.split('.').length === 3, 'Returned valid signed JWT token (header.payload.signature)');

  } catch (err) {
    console.error('Unexpected test error:', err);
    failed++;
  }

  console.log('\n====================================================');
  console.log(`📊 Test Results: ${passed} Passed, ${failed} Failed`);
  console.log('====================================================');

  if (failed > 0) process.exit(1);
}

runTests();
