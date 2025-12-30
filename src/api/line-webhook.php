<?php
/**
 * LINE Webhook Endpoint
 *
 * Receives messages from LINE OA and forwards to Claude for processing.
 * Sends Claude's response back to the user via LINE.
 *
 * @package XClaude Framework
 */

// Load environment
require_once __DIR__ . '/../../config/bootstrap.php';

// LINE Configuration
$channelSecret = getenv('LINE_CHANNEL_SECRET') ?: '';
$channelAccessToken = getenv('LINE_CHANNEL_ACCESS_TOKEN') ?: '';
$claudeApiKey = getenv('CLAUDE_API_KEY') ?: '';

// Allowed users for Claude AI (comma-separated LINE User IDs)
// If empty, all users can use. If set, only listed users can use Claude AI
$allowedUsers = array_filter(array_map('trim', explode(',', getenv('ALLOWED_LINE_USERS') ?: '')));

// Get request body
$requestBody = file_get_contents('php://input');

// Verify LINE signature
$signature = $_SERVER['HTTP_X_LINE_SIGNATURE'] ?? '';
if (!verifySignature($requestBody, $signature, $channelSecret)) {
    http_response_code(400);
    exit('Invalid signature');
}

// Parse events
$events = json_decode($requestBody, true);

if (!isset($events['events'])) {
    http_response_code(200);
    exit('OK');
}

// Process each event
foreach ($events['events'] as $event) {
    if ($event['type'] === 'message' && $event['message']['type'] === 'text') {
        $userId = $event['source']['userId'];
        $userMessage = $event['message']['text'];
        $replyToken = $event['replyToken'];

        // Check if user is authorized for Claude AI
        $isAuthorized = empty($allowedUsers) || in_array($userId, $allowedUsers);

        // Get response (Claude AI only for authorized users)
        $response = processMessage($userMessage, $userId, $claudeApiKey, $isAuthorized);

        // Reply to user
        replyMessage($replyToken, $response, $channelAccessToken);
    }
}

http_response_code(200);
echo 'OK';

/**
 * Verify LINE webhook signature
 */
function verifySignature(string $body, string $signature, string $channelSecret): bool {
    if (empty($channelSecret)) {
        return true; // Skip verification if secret not set (development)
    }

    $hash = base64_encode(hash_hmac('sha256', $body, $channelSecret, true));
    return hash_equals($hash, $signature);
}

/**
 * Process message with authorization check
 */
function processMessage(string $message, string $userId, string $apiKey, bool $isAuthorized): string {
    // Check for admin commands
    if (preg_match('/^\/myid$/i', trim($message))) {
        return "🆔 Your LINE User ID:\n{$userId}\n\nใช้ ID นี้ใส่ใน ALLOWED_LINE_USERS";
    }

    // If Claude API not configured OR user not authorized, use simple mode
    if (empty($apiKey) || !$isAuthorized) {
        return getSimpleResponse($message, !$isAuthorized && !empty($apiKey));
    }

    // User is authorized and Claude API is available
    return askClaude($message, $userId, $apiKey);
}

/**
 * Ask Claude and get response (for authorized users only)
 */
function askClaude(string $message, string $userId, string $apiKey): string {
    // Load conversation history
    $history = loadConversationHistory($userId);

    // Add user message to history
    $history[] = [
        'role' => 'user',
        'content' => $message
    ];

    // System prompt for Claude
    $systemPrompt = getSystemPrompt();

    // Call Claude API
    $response = callClaudeAPI($systemPrompt, $history, $apiKey);

    if ($response['success']) {
        // Add assistant response to history
        $history[] = [
            'role' => 'assistant',
            'content' => $response['message']
        ];

        // Keep only last 20 messages to manage context
        if (count($history) > 20) {
            $history = array_slice($history, -20);
        }

        // Save conversation history
        saveConversationHistory($userId, $history);

        return $response['message'];
    }

    return "Error: " . $response['error'];
}

/**
 * Get simple response when Claude API is not configured or user not authorized
 * Provides basic status info and helpful messages
 */
function getSimpleResponse(string $message, bool $isRestricted = false): string {
    $projectName = getenv('APP_NAME') ?: 'XClaude Project';
    $siteUrl = getenv('SITE_URL') ?: '';

    // Check for status-related keywords
    if (preg_match('/(status|สถานะ|deploy|ดีพลอย)/iu', $message)) {
        return getDeployStatus();
    }

    // Check for help keywords
    if (preg_match('/(help|ช่วย|วิธี|how)/iu', $message)) {
        $helpText = "📋 {$projectName}\n\n" .
                    "คำสั่งที่ใช้ได้:\n" .
                    "• พิมพ์ 'status' หรือ 'สถานะ' - ดูสถานะ deploy\n" .
                    "• พิมพ์ 'url' - ดู URL ของเว็บไซต์\n" .
                    "• พิมพ์ '/myid' - ดู LINE User ID ของคุณ\n" .
                    "• พิมพ์ 'help' - ดูความช่วยเหลือ\n\n";
        if ($siteUrl) {
            $helpText .= "🌐 Website: {$siteUrl}";
        }
        return $helpText;
    }

    // Check for URL keywords
    if (preg_match('/(url|link|ลิงก์|เว็บ)/iu', $message)) {
        if ($siteUrl) {
            return "🌐 Website URL:\n{$siteUrl}";
        }
        return "❌ ยังไม่ได้ตั้งค่า SITE_URL";
    }

    // Check for greeting
    if (preg_match('/(สวัสดี|hello|hi|หวัดดี)/iu', $message)) {
        return "สวัสดีครับ! 👋\n\n" .
               "ผมเป็น Bot ของ {$projectName}\n" .
               "พิมพ์ 'help' เพื่อดูคำสั่งที่ใช้ได้";
    }

    // Default response - different message for restricted vs no API key
    if ($isRestricted) {
        return "📌 {$projectName} Bot\n\n" .
               "🔒 คุณใช้งานโหมด AI ไม่ได้\n" .
               "เฉพาะ Admin เท่านั้นที่ใช้ได้\n\n" .
               "พิมพ์ 'help' เพื่อดูคำสั่งที่ใช้ได้";
    }

    return "📌 {$projectName} Bot\n\n" .
           "ขณะนี้ Bot ทำงานในโหมดแจ้งเตือน\n" .
           "พิมพ์ 'help' เพื่อดูคำสั่งที่ใช้ได้\n\n" .
           "💡 ต้องการให้ Bot ตอบคำถามได้อัจฉริยะ?\n" .
           "ตั้งค่า CLAUDE_API_KEY ใน .env";
}

/**
 * Get deploy status from feedback file
 */
function getDeployStatus(): string {
    $feedbackFile = __DIR__ . '/../../.deploy-feedback.json';
    $projectName = getenv('APP_NAME') ?: 'XClaude Project';

    if (!file_exists($feedbackFile)) {
        return "📊 สถานะ Deploy\n\n" .
               "ยังไม่มีข้อมูล deploy\n" .
               "(ไม่พบไฟล์ .deploy-feedback.json)";
    }

    $data = json_decode(file_get_contents($feedbackFile), true);

    if (!$data) {
        return "❌ ไม่สามารถอ่านข้อมูล deploy ได้";
    }

    $status = $data['status'] ?? 'unknown';
    $version = $data['version'] ?? '-';
    $timestamp = $data['timestamp'] ?? '-';
    $siteUrl = $data['site_url'] ?? getenv('SITE_URL') ?: '-';

    $statusIcon = $status === 'success' ? '✅' : '❌';
    $statusText = $status === 'success' ? 'สำเร็จ' : 'ล้มเหลว';

    $response = "📊 สถานะ Deploy - {$projectName}\n\n" .
                "{$statusIcon} สถานะ: {$statusText}\n" .
                "🏷️ Version: {$version}\n" .
                "🕐 เวลา: {$timestamp}\n";

    if ($siteUrl !== '-') {
        $response .= "🌐 URL: {$siteUrl}\n";
    }

    if (!empty($data['errors'])) {
        $response .= "\n❌ Errors:\n";
        foreach (array_slice($data['errors'], 0, 3) as $error) {
            $response .= "• {$error}\n";
        }
    }

    return $response;
}

/**
 * Get system prompt for Claude
 */
function getSystemPrompt(): string {
    $projectName = getenv('APP_NAME') ?: 'XClaude Project';
    $siteUrl = getenv('SITE_URL') ?: '';

    return <<<PROMPT
You are Claude, an AI assistant integrated with LINE OA for the {$projectName} project.

You help users with:
1. Answering questions about the project
2. Providing status updates on deployments
3. Helping with code-related queries
4. General assistance

Project URL: {$siteUrl}

Guidelines:
- Keep responses concise (LINE has message limits)
- Use Thai or English based on user's language
- Be helpful and friendly
- For complex code, suggest viewing on the website or GitHub

If the user asks about deployment status or wants to trigger actions, inform them of the current capabilities.
PROMPT;
}

/**
 * Call Claude API
 */
function callClaudeAPI(string $systemPrompt, array $messages, string $apiKey): array {
    $url = 'https://api.anthropic.com/v1/messages';

    $data = [
        'model' => 'claude-sonnet-4-20250514',
        'max_tokens' => 1024,
        'system' => $systemPrompt,
        'messages' => $messages
    ];

    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => json_encode($data),
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/json',
            'x-api-key: ' . $apiKey,
            'anthropic-version: 2023-06-01'
        ],
        CURLOPT_TIMEOUT => 30
    ]);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);

    if ($error) {
        return ['success' => false, 'error' => $error];
    }

    $result = json_decode($response, true);

    if ($httpCode !== 200) {
        $errorMsg = $result['error']['message'] ?? 'Unknown error';
        return ['success' => false, 'error' => $errorMsg];
    }

    $message = $result['content'][0]['text'] ?? '';
    return ['success' => true, 'message' => $message];
}

/**
 * Reply to LINE message
 */
function replyMessage(string $replyToken, string $message, string $accessToken): void {
    // LINE has a 5000 character limit per message
    // Split long messages if needed
    $messages = splitMessage($message, 4500);

    $lineMessages = array_map(function($text) {
        return ['type' => 'text', 'text' => $text];
    }, $messages);

    // LINE allows max 5 messages per reply
    $lineMessages = array_slice($lineMessages, 0, 5);

    $data = [
        'replyToken' => $replyToken,
        'messages' => $lineMessages
    ];

    $ch = curl_init('https://api.line.me/v2/bot/message/reply');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => json_encode($data),
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/json',
            'Authorization: Bearer ' . $accessToken
        ]
    ]);

    curl_exec($ch);
    curl_close($ch);
}

/**
 * Split message into chunks
 */
function splitMessage(string $message, int $maxLength): array {
    if (mb_strlen($message) <= $maxLength) {
        return [$message];
    }

    $chunks = [];
    $lines = explode("\n", $message);
    $currentChunk = '';

    foreach ($lines as $line) {
        if (mb_strlen($currentChunk . "\n" . $line) > $maxLength) {
            if ($currentChunk) {
                $chunks[] = $currentChunk;
            }
            $currentChunk = $line;
        } else {
            $currentChunk .= ($currentChunk ? "\n" : '') . $line;
        }
    }

    if ($currentChunk) {
        $chunks[] = $currentChunk;
    }

    return $chunks;
}

/**
 * Load conversation history from storage
 */
function loadConversationHistory(string $userId): array {
    $storageDir = __DIR__ . '/../../storage/conversations';
    $file = $storageDir . '/' . md5($userId) . '.json';

    if (!file_exists($file)) {
        return [];
    }

    $data = json_decode(file_get_contents($file), true);

    // Check if conversation is stale (more than 1 hour old)
    if (isset($data['updated_at'])) {
        $lastUpdate = strtotime($data['updated_at']);
        if (time() - $lastUpdate > 3600) {
            return []; // Start fresh conversation
        }
    }

    return $data['messages'] ?? [];
}

/**
 * Save conversation history to storage
 */
function saveConversationHistory(string $userId, array $messages): void {
    $storageDir = __DIR__ . '/../../storage/conversations';

    if (!is_dir($storageDir)) {
        mkdir($storageDir, 0755, true);
    }

    $file = $storageDir . '/' . md5($userId) . '.json';

    $data = [
        'user_id' => $userId,
        'updated_at' => date('c'),
        'messages' => $messages
    ];

    file_put_contents($file, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}
