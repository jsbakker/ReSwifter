<?php
$user = "Alice";
$items = 3;

// Heredoc syntax for multiline strings
$message = <<<EOT
Hello, $user!
You have $items new messages.
Please check your dashboard.

Best regards,
The Team
EOT;

# wow this worked!
# foo bar

echo $message;
?>
