// Create connection
$conn = new mysqli($servername, $username, $password, $dbname, $port);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

// Process form
if ($_SERVER["REQUEST_METHOD"] == "POST") {

  $name    = htmlspecialchars($_POST["name"] ?? '');
  $email   = htmlspecialchars($_POST["email"] ?? '');
  $website = htmlspecialchars($_POST["website"] ?? '');
  $comment = htmlspecialchars($_POST["comment"] ?? '');
  $gender  = htmlspecialchars($_POST["gender"] ?? '');

  if (empty($name) || empty($email) || empty($gender)) {
    die("Required fields missing!");
  }

  if(!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    die("Invalid email format!");
  }

  $stmt = $conn->prepare(
    "INSERT INTO users (name, email, website, comment, gender)
     VALUES (?, ?, ?, ?, ?)"
  );

  if (!$stmt) {
    die("Prepare failed: " . $conn->error);
  }

  $stmt->bind_param("sssss", $name, $email, $website, $comment, $gender);

  if ($stmt->execute()) {
    echo "New record created successfully!";
  } else {
    echo "Error: " . $stmt->error;
  }

  $stmt->close();
}

$conn->close();
?>
