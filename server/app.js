
const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();
const bcrypt = require('bcrypt');
const con = require('./spb'); // Database connection
const cookieParser = require('cookie-parser');

app.use(cookieParser());
app.use(express.json());

const JWT_KEY = 'm0bile2Simple';
authenticateToken



// ======================= Middleware functions ===================
function authenticateToken(userType) {
    return function (req, res, next) {
        let token = req.headers['authorization'] || req.headers['x-access-token'];
        if (token == undefined || token == null) {
            // no token
            return res.status(400).send('No token');
        }


        // token found
        if (req.headers.authorization) {
            const tokenString = token.split(' ');
            if (tokenString[0] == 'Bearer') {
                token = tokenString[1];
            }
        }
        jwt.verify(token, JWT_KEY, (err, decoded) => {
            if (err) {
                res.status(401).send('Incorrect token');
            }
            console.log("Decoded Role:", decoded.role);
            console.log("Expected User Role:", userType)
            if (!userType.includes(decoded.role)) {
                res.status(403).send('Unauthorized');
            }
            else {
                req.decoded = decoded;
                next();
            }
        });
    }
}


// ฟังก์ชันดึงข้อมูลผู้ใช้จากฐานข้อมูล โดยใช้ user_id
function getUserById(userId) {
    return new Promise((resolve, reject) => {
        con.query(
            'SELECT * FROM users WHERE user_id = ?',  // ใช้ user_id แทน username
            [userId], // ใช้ parameterized query เพื่อลดความเสี่ยงจาก SQL Injection
            (err, results) => {
                if (err) {
                    return reject(err); // Reject if there's an error
                }
                resolve(results[0]); // Resolve with the user data
            }
        );
    });
}
// Express route to handle profile fetching
app.get('/profile', authenticateToken(['Student', 'Staff', 'Lender']), async (req, res) => {
    const userId = req.decoded.user_id; // Get user_id from the JWT token (from req.decoded)
    
    try {
        const user = await getUserById(userId);  // Retrieve user based on user_id
        if (user) {
            res.json(user);  // If user found, send their data as response
        } else {
            res.status(404).json({ message: 'User not found' });  // If no user found, send 404
        }
    } catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

app.post('/login', (req, res) => {
    const { username, password, rememberMe } = req.body;
    const sql = "SELECT user_id, password, role FROM users WHERE username = ?";

    console.log("Received login request:", { username, password });

    con.query(sql, [username], function (err, results) {
        if (err) {
            console.error("Database query error:", err);
            return res.status(500).json({ message: 'Server error' });
        }
        if (results.length === 0) {
            return res.status(400).json({ message: 'Wrong username' });
        }

        const hash = results[0].password;
        const role = results[0].role;

        bcrypt.compare(password, hash, function (err, same) {
            if (err) {
                console.error("Password comparison error:", err);
                return res.status(500).json({ message: 'Hash error' });
            }
            if (!same) {
                return res.status(401).json({ message: 'Login fail' });
            }

            // สร้าง payload และ JWT token
            const payload = {
                user_id: results[0].user_id,
                role: role,
                username: username
            };
            const token = jwt.sign(payload, JWT_KEY, { expiresIn: rememberMe ? '30d' : '1d' });

            // ส่ง token กลับให้ client
            res.json({ message: 'Login ok', token: token, user_id: results[0].user_id, role: role });
        });
    });
});


// Route to hash password (for testing purposes)
app.get('/password/:raw', (req, res) => {
    const raw = req.params.raw;
    bcrypt.hash(raw, 10, function (err, hash) {
        if (err) {
            return res.status(500).send('Hashing error');
        }
        res.send(hash);
    });
});



// Register route
app.post('/register', (req, res) => {
    const { username, password, email } = req.body;

    if (!username || !password || !email) {
        return res.status(400).json({ message: 'Username, email, and password are required' });
    }

    const checkUserSql = "SELECT * FROM users WHERE username = ? OR email = ?";
    con.query(checkUserSql, [username, email], (err, results) => {
        if (err) return res.status(500).json({ message: 'Database error' });
        if (results.length > 0) return res.status(400).json({ message: 'Username or Email already exists' });

        bcrypt.hash(password, 10, (err, hash) => {
            if (err) return res.status(500).json({ message: 'Error hashing password' });

            const sql = "INSERT INTO users (username, password, email, role) VALUES (?, ?, ?, 'Student')";
            con.query(sql, [username, hash, email], (err, result) => {
                if (err) return res.status(500).json({ message: 'Database error' });

                const token = jwt.sign({ username, role: 'Student' }, JWT_KEY, { expiresIn: '1h' });
                res.status(201).json({ message: 'User registered successfully!', token });
            });
        });
    });
});


// Logout route
app.post('/logout', (req, res) => {
    res.json({ message: 'Logout successful' });
});

app.use('/images', express.static('public/images'));

app.put('/assets/:id', (req, res) => {
    const assetId = req.params.id;
    const newStatus = req.body.status; // Expecting JSON body with status field

    const sql = 'UPDATE assets SET status = ? WHERE asset_id = ?';
    con.query(sql, [newStatus, assetId], (err, results) => {
        if (err) {
            console.error('Error updating asset status:', err);
            res.status(500).json({ error: 'Failed to update status' });
            return;
        }
        if (results.affectedRows === 0) {
            res.status(404).json({ error: 'Asset not found' });
            return;
        }
        res.json({ message: 'Status updated successfully' });
    });
});


app.put('/assets/disable/:asset_id', (req, res) => {
    const assetId = req.params.asset_id;

    // คำสั่ง SQL เพื่อดึงสถานะปัจจุบันของ asset
    const getStatusSql = 'SELECT status FROM assets WHERE asset_id = ?';
    
    con.query(getStatusSql, [assetId], (err, results) => {
        if (err) {
            console.error('Error fetching asset status:', err);
            return res.status(500).json({ error: 'Failed to fetch status' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Asset not found' });
        }

        const currentStatus = results[0].status;
        const newStatus = currentStatus === 'Disabled' ? 'Available' : 'Disabled';  // เปลี่ยนสถานะ

        // คำสั่ง SQL เพื่ออัพเดตสถานะในฐานข้อมูล
        const updateStatusSql = 'UPDATE assets SET status = ? WHERE asset_id = ?';

        con.query(updateStatusSql, [newStatus, assetId], (err, results) => {
            if (err) {
                console.error('Error updating asset status:', err);
                return res.status(500).json({ error: 'Failed to update status' });
            }

            if (results.affectedRows === 0) {
                return res.status(404).json({ error: 'Asset not found' });
            }

            // ส่งข้อความตอบกลับเมื่ออัพเดตสถานะสำเร็จ
            res.json({ message: `Status updated to ${newStatus} successfully` });
        });
    });
});



// Home route
app.get('/', (req, res) => {
    
        res.send('Hello! Please log in.');
    
});

app.post('/add/assets', (req, res) => {
    const { asset_name, status, asset_image, assets_description } = req.body;

    console.log('Request body:', req.body);

    const sql = 'INSERT INTO assets ( asset_name, status, asset_image, assets_description) VALUES ( ?, ?, ?, ?)';

    con.query(sql, [ asset_name, status, asset_image, assets_description], (err, result) => {
        if (err) {
            console.error('Error during SQL query:', err);
            return res.status(500).json({ message: 'Error adding asset' });
        }

        console.log('Insert result:', result);
        res.status(201).json({ message: 'Asset added successfully', assetId: result.insertId });
    });
});


app.put('/edit/assets/:asset_id', (req, res) => {
    const assetId = req.params.asset_id;
    const { asset_name, assets_description ,asset_image} = req.body;

    console.log('Request body:', req.body);
    console.log('Asset ID to edit:', assetId);

    // SQL query to update only the asset_name and assets_description
    const sql = 'UPDATE assets SET asset_name = ?,asset_image = ?, assets_description = ? WHERE asset_id = ?';

    con.query(sql, [asset_name,asset_image, assets_description, assetId], (err, result) => {
        if (err) {
            console.error('Error during SQL query:', err);
            return res.status(500).json({ message: 'Error updating asset' });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Asset not found' });
        }

        console.log('Update result:', result);
        res.status(200).json({ message: 'Asset updated successfully' });
    });
});


// Borrow request route
app.post('/borrow', authenticateToken('Student'), (req, res) => {
    const { asset_id, borrow_date, return_date } = req.body;

    // ตรวจสอบว่า token ถูกต้อง และดึงข้อมูลจาก decoded
    const borrower_id = req.decoded.user_id; // ใช้ข้อมูลจาก decoded ที่มาจาก JWT token

    if (!asset_id || !borrow_date || !return_date) {
        console.error("Borrow request error: Asset ID, borrow date, and return date are required");
        return res.status(400).json({ message: 'Asset ID, borrow date, and return date are required' });
    }

    // เช็คว่าผู้ใช้ยืมทรัพย์สินในวันนี้หรือไม่
    const checkBorrowedTodaySql = `
        SELECT * FROM borrowrequests 
        WHERE borrower_id = ? AND DATE(borrow_date) = CURDATE() AND status = 'Pending'`;

    con.query(checkBorrowedTodaySql, [borrower_id], (checkErr, checkResult) => {
        if (checkErr) {
            console.error("Database error during borrow check:", checkErr);
            return res.status(500).json({ message: 'Database error' });
        }

        // หากผู้ใช้มีคำขอยืมที่ยังค้างอยู่ในวันนี้
        if (checkResult.length > 0) {
            return res.status(400).json({ message: 'You have already borrowed today. Please return the asset before borrowing again.' });
        }

        // ตรวจสอบสถานะของทรัพย์สิน
        const checkAssetSql = "SELECT status FROM assets WHERE asset_id = ?";
        con.query(checkAssetSql, [asset_id], (checkErr, checkResult) => {
            if (checkErr) {
                console.error("Database error during asset status check:", checkErr);
                return res.status(500).json({ message: 'Database error' });
            }

            if (checkResult.length === 0 || checkResult[0].status !== 'Available') {
                return res.status(400).json({ message: 'Asset is not available for borrowing' });
            }

            // สร้างคำขอยืมใหม่
            const sql = "INSERT INTO borrowrequests (borrower_id, asset_id, borrow_date, return_date) VALUES (?, ?, ?, ?)";
            con.query(sql, [borrower_id, asset_id, borrow_date, return_date], (err, result) => {
                if (err) {
                    console.error("Database error during borrow request:", err);
                    return res.status(500).json({ message: 'Database error' });
                }

                // อัพเดตสถานะของทรัพย์สินเป็น 'Pending'
                const updateAssetStatusSql = "UPDATE assets SET status = 'Pending' WHERE asset_id = ?";
                con.query(updateAssetStatusSql, [asset_id], (updateErr) => {
                    if (updateErr) {
                        console.error("Database error during asset status update:", updateErr);
                        return res.status(500).json({ message: 'Database error' });
                    }

                    console.log("Borrow request submitted successfully:", { borrower_id, asset_id, borrow_date, return_date });
                    res.status(201).json({ message: 'Borrow request submitted successfully!' });
                });
            });
        });
    });
});


app.post('/approve/:request_id',authenticateToken('Lender'), (req, res) => {
    const requestId = req.params.request_id;

    // รับ lender_id จาก body request
    const lender_id = req.decoded.user_id; // ค่าของ lender_id ต้องถูกส่งมาจาก body

    // ตรวจสอบสถานะที่ส่งมา (ต้องเป็น "Approved" หรือ "Disapproved")
    const status = req.body.status; // 'Approved' หรือ 'Disapproved'
    console.log('Request ID:', requestId);
    console.log('Lender ID:', lender_id);
    console.log('Status:', status);
    // ตรวจสอบว่า status เป็น undefined หรือไม่
if (!status) {
  console.log('Error: Status is missing or undefined');
}
    if (!['Approved', 'Rejected'].includes(status)) {
        return res.status(400).json({ message: 'Invalid status' });
    }

    if (!lender_id) {
        return res.status(400).json({ message: 'Lender ID is required' });
    }

    // อัปเดตสถานะของคำขอในฐานข้อมูล
    const sql = "UPDATE borrowrequests SET status = ?, approved_by = ? WHERE request_id = ?";

    con.query(sql, [status, lender_id, requestId], (err, result) => {
        if (err) {
            console.error("Database error during approval:", err);
            return res.status(500).json({ message: 'Database error' });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Request not found' });
        }

        // อัปเดตสถานะของทรัพย์สิน
        const assetStatus = status === 'Approved' ? 'Borrowed' : 'Available';
        const updateAssetSql = `
            UPDATE assets 
            SET status = ? 
            WHERE asset_id = (SELECT asset_id FROM borrowrequests WHERE request_id = ?)
        `;

        con.query(updateAssetSql, [assetStatus, requestId], (updateErr) => {
            if (updateErr) {
                console.error("Database error during asset status update:", updateErr);
                return res.status(500).json({ message: 'Database error' });
            }

            console.log(`Borrow request ${requestId} ${status.toLowerCase()} successfully.`);
            res.json({ message: `Borrow request ${status.toLowerCase()} successfully!` });
        });
    });
});





// Delete borrowing request and update asset status route
app.delete('/cancle/:request_id', (req, res) => {
    const requestId = req.params.request_id;

    // Start a transaction
    con.beginTransaction((err) => {
        if (err) {
            console.error("Transaction start error:", err);
            return res.status(500).json({ message: 'Transaction error' });
        }

        // SQL query to delete the borrowing request
        const updateSql = "UPDATE assets SET status = 'Available' WHERE asset_id = (SELECT asset_id FROM borrowrequests WHERE request_id = ?)";

        con.query(updateSql, [requestId], (err, result) => {
            if (err) {
                return con.rollback(() => {
                    console.error("Error updating borrow request:", err);
                    return res.status(500).json({ message: 'Database error during updating' });
                });
            }

            if (result.affectedRows === 0) {
                return con.rollback(() => {
                    return res.status(404).json({ message: 'Request not found' });
                });
            }

            console.log('Borrow request ${requestId} updated successfully.');

            // SQL query to update the asset status to 'Available'
            const deleteSql = "DELETE FROM borrowrequests WHERE request_id = ?";

            con.query(deleteSql, [requestId], (err, updateResult) => {
                if (err) {
                    return con.rollback(() => {
                        console.error("Error deleting asset status:", err);
                        return res.status(500).json({ message: 'Error deleting asset status' });
                    });
                }

                // Commit the transaction if both queries were successful
                con.commit((err) => {
                    if (err) {
                        return con.rollback(() => {
                            console.error("Transaction commit error:", err);
                            return res.status(500).json({ message: 'Error committing transaction' });
                        });
                    }

                    console.log("Asset status updated to 'Available' successfully.");
                    res.json({ message: 'Borrow request deleted and asset status updated successfully!' });
                });
            });
        });
    });
});


app.get('/borrowrequestsforstu', authenticateToken(['Student', 'Lender']), (req, res) => {
    const borrowerId = req.decoded.user_id; // Assume req.user.id contains the authenticated user's ID
    const sql = "SELECT * FROM borrowrequests WHERE borrower_id = ?";

    con.query(sql, [borrowerId], (err, results) => {
        if (err) {
            console.error("Error fetching borrowing requests:", err);
            return res.status(500).json({ message: 'Failed to retrieve borrowing requests' });
        }

        res.json(results);
    });
});
// Endpoint to get borrowing requests
app.get('/borrowrequests', authenticateToken(['Student','Lender']), (req, res) => {
    const sql = "SELECT * FROM borrowrequests";

    con.query(sql, (err, results) => {
        if (err) {
            console.error("Error fetching borrowing requests:", err);
            return res.status(500).json({ message: 'Failed to retrieve borrowing requests' });
        }

        res.json(results);
    });
});



app.get('/assets', (req, res) => {
    const sql = 'SELECT * FROM assets';
    con.query(sql, (err, results) => {
        if (err) {
            console.error('Error fetching data:', err);
            res.status(500).json({ error: 'Failed to retrieve data' });
            return;
        }
        res.json(results);
    });
});
// new moeyu
// Get Student History API Endpoint
app.get('/api/history/student/:userId', authenticateToken('Student'), (req, res) => {
    const userId = req.decoded.user_id;
    const query = `
        SELECT br.request_id, a.asset_name, br.borrow_date, br.return_date,
               CASE 
                   WHEN br.status = 'Approved' AND a.status = 'Borrowed' THEN 'Borrowed'
                   WHEN br.status = 'Approved' AND a.status = 'Available' THEN 'Returned'
                   ELSE br.status 
               END AS status,
               a.asset_image, a.status AS asset_status,
               u.username AS approver_name
        FROM borrowrequests br
        JOIN assets a ON br.asset_id = a.asset_id
        LEFT JOIN users u ON br.approved_by = u.user_id
        WHERE br.borrower_id = ?;
    `;

    con.query(query, [userId], (err, results) => {
        if (err) {
            console.error('Error fetching student history:', err);
            return res.status(500).json({ error: 'Failed to fetch history' });
        }
        res.json(results);
    });
});

// // check it laaa
// // Get Student History API Endpoint
// app.get('/api/history/student/:userId', authenticateToken('Student'), (req, res) => {
//     const userId = req.decoded.user_id;
//     const query = `
//         SELECT br.request_id, a.asset_name, br.borrow_date, br.return_date, br.status, a.asset_image, a.status AS asset_status
//         FROM borrowrequests br
//         JOIN assets a ON br.asset_id = a.asset_id
//         WHERE br.borrower_id = ?;
//     `;

//     con.query(query, [userId], (err, results) => {
//         if (err) {
//             console.error('Error fetching student history:', err);
//             return res.status(500).json({ error: 'Failed to fetch history' });
//         }
//         res.json(results);
//     });
// });


// Get Lender History API Endpoint
app.get('/api/history/lender/:userId',authenticateToken('Lender'), (req, res) => {
    const  userId  = req.decoded.user_id;
    const query = `
        SELECT br.request_id, a.asset_name, u.username AS borrower, br.borrow_date, br.return_date, br.status, a.asset_image, a.status AS asset_status
        FROM borrowrequests br
        JOIN assets a ON br.asset_id = a.asset_id
        JOIN users u ON br.borrower_id = u.user_id
        WHERE br.approved_by = ?;
    `;

    con.query(query, [userId], (err, results) => {
        if (err) {
            console.error('Error fetching lender history:', err);
            return res.status(500).json({ error: 'Failed to fetch history' });
        }
        res.json(results);
    });
});

// Get Staff History API Endpoint
app.get('/api/history/staff/:userId', authenticateToken('Staff'), (req, res) => {
    const userId = req.decoded.user_id;
    const query = `
        SELECT br.request_id, a.asset_name, borrower.username AS borrower, approver.username AS approvedBy,
               br.borrow_date, br.return_date, 
               CASE 
                   WHEN br.status = 'Approved' AND a.status = 'Borrowed' THEN 'Borrowed'
                   WHEN br.status = 'Approved' AND a.status = 'Available' THEN 'Returned'
                   ELSE br.status 
               END AS status,
               a.asset_image, a.status AS asset_status
        FROM borrowrequests br
        JOIN assets a ON br.asset_id = a.asset_id
        JOIN users borrower ON br.borrower_id = borrower.user_id
        LEFT JOIN users approver ON br.approved_by = approver.user_id;
    `;

    con.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching staff history:', err);
            return res.status(500).json({ error: 'Failed to fetch history' });
        }
        res.json(results);
    });
});


// Get Returning Assets API Endpoint
app.get('/api/assets/returning', (req, res) => {
    const query = `
        SELECT a.asset_id, a.asset_name, borrower.username AS borrower, br.borrow_date, 
               approver.username AS approvedBy, a.asset_image, br.return_date, br.status
        FROM borrowrequests br
        JOIN assets a ON br.asset_id = a.asset_id
        JOIN users borrower ON br.borrower_id = borrower.user_id
        LEFT JOIN users approver ON br.approved_by = approver.user_id
        WHERE br.status = 'Approved' AND a.status = 'Borrowed';
    `;

    con.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching returning assets:', err);
            return res.status(500).json({ error: 'Failed to fetch returning assets' });
        }
        res.json(results);
    });
});


// Update Asset Status to Available (Staff Returning Asset)
app.put('/api/assets/return/:assetId', (req, res) => {
    const assetId = req.params.assetId;

    const updateAssetSql = "UPDATE assets SET status = 'Available' WHERE asset_id = ?";

    con.query(updateAssetSql, [assetId], (err, result) => {
        if (err) {
            console.error("Database error during asset status update:", err);
            return res.status(500).json({ message: 'Database error' });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Asset not found' });
        }

        console.log(`Asset ${assetId} returned successfully.`);
        res.json({ message: 'Asset returned successfully!' });
    });
});
// // Get Staff History API Endpoint
// app.get('/api/history/staff', (req, res) => {
//     const query = `
//         SELECT br.request_id, a.asset_name, borrower.username AS borrower, approver.username AS approvedBy, br.borrow_date, br.return_date, br.status, a.asset_image, a.status AS asset_status
//         FROM borrowrequests br
//         JOIN assets a ON br.asset_id = a.asset_id
//         JOIN users borrower ON br.borrower_id = borrower.user_id
//         LEFT JOIN users approver ON br.approved_by = approver.user_id;
//     `;

//     con.query(query, (err, results) => {
//         if (err) {
//             console.error('Error fetching staff history:', err);
//             return res.status(500).json({ error: 'Failed to fetch history' });
//         }
//         res.json(results);
//     });
// });

// // Get Returning Assets API Endpoint
// app.get('/api/assets/returning', (req, res) => {
//     const query = `
//         SELECT a.asset_id, a.asset_name, borrower.username AS borrower, br.borrow_date, approver.username AS approvedBy, a.asset_image, br.return_date, br.status
//         FROM borrowrequests br
//         JOIN assets a ON br.asset_id = a.asset_id
//         JOIN users borrower ON br.borrower_id = borrower.user_id
//         LEFT JOIN users approver ON br.approved_by = approver.user_id
//         WHERE br.status = 'Approved';
//     `;

//     con.query(query, (err, results) => {
//         if (err) {
//             console.error('Error fetching returning assets:', err);
//             return res.status(500).json({ error: 'Failed to fetch returning assets' });
//         }
//         res.json(results);
//     });
// });

// // Update Asset Status to Available (Staff Returning Asset)
// app.put('/api/assets/return/:assetId', (req, res) => {
//     const assetId = req.params.assetId;

//     const updateAssetSql = "UPDATE assets SET status = 'Available' WHERE asset_id = ?";

//     con.query(updateAssetSql, [assetId], (err, result) => {
//         if (err) {
//             console.error("Database error during asset status update:", err);
//             return res.status(500).json({ message: 'Database error' });
//         }

//         if (result.affectedRows === 0) {
//             return res.status(404).json({ message: 'Asset not found' });
//         }

//         console.log(`Asset ${assetId} returned successfully.`);
//         res.json({ message: 'Asset returned successfully!' });
//     });
// });
// check it laaa
// Dashboard Data API Endpoint
app.get('/api/dashboard', (req, res) => {
    const query = `
        SELECT 
            SUM(CASE WHEN status = 'Available' THEN 1 ELSE 0 END) AS available_assets,
            SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS pending_assets,
            SUM(CASE WHEN status = 'Borrowed' THEN 1 ELSE 0 END) AS borrowed_assets,
            SUM(CASE WHEN status = 'Disabled' THEN 1 ELSE 0 END) AS disabled_assets
        FROM assets;
    `;

    con.query(query, (err, results) => {
        if (err) {
            console.error('Error fetching dashboard data:', err);
            return res.status(500).json({ error: 'Failed to fetch dashboard data' });
        }
        res.json(results[0]);
    });
});

// ---------- Server starts here ---------
const PORT = 3000;
app.listen(PORT, () => {
    console.log('Server is running at :' + PORT);
});
