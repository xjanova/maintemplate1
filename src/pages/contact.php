<?php
/**
 * หน้าติดต่อ (Contact Page)
 */
$pageTitle = 'ติดต่อ - ' . APP_NAME;
?>

<section class="py-20 bg-white dark:bg-gray-900">
    <div class="max-w-2xl mx-auto px-4">
        <h1 class="text-4xl font-bold text-gray-900 dark:text-white mb-4 text-center">
            ติดต่อเรา
        </h1>
        <p class="text-gray-600 dark:text-gray-400 text-center mb-12">
            มีคำถามหรือข้อเสนอแนะ? ติดต่อเราได้เลย
        </p>

        <!-- Contact Form with HTMX -->
        <form hx-post="<?= url('/api/contact') ?>"
              hx-target="#form-result"
              hx-swap="innerHTML"
              x-data="{ sending: false }"
              @htmx:before-request="sending = true"
              @htmx:after-request="sending = false"
              class="space-y-6 bg-gray-50 dark:bg-gray-800 rounded-2xl p-8">

            <?= csrf_field() ?>

            <!-- Name -->
            <div>
                <label for="name" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    ชื่อ
                </label>
                <input type="text"
                       id="name"
                       name="name"
                       required
                       class="w-full px-4 py-3 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all">
            </div>

            <!-- Email -->
            <div>
                <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    อีเมล
                </label>
                <input type="email"
                       id="email"
                       name="email"
                       required
                       class="w-full px-4 py-3 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all">
            </div>

            <!-- Message -->
            <div>
                <label for="message" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    ข้อความ
                </label>
                <textarea id="message"
                          name="message"
                          rows="5"
                          required
                          class="w-full px-4 py-3 rounded-xl border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-primary-500 focus:border-transparent transition-all resize-none"></textarea>
            </div>

            <!-- Submit -->
            <button type="submit"
                    :disabled="sending"
                    class="w-full px-8 py-3 bg-primary-600 hover:bg-primary-700 disabled:bg-primary-400 text-white font-semibold rounded-xl shadow-lg transition-all flex items-center justify-center space-x-2">
                <span x-show="!sending">ส่งข้อความ</span>
                <span x-show="sending" x-cloak class="flex items-center space-x-2">
                    <svg class="animate-spin h-5 w-5" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"/>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
                    </svg>
                    <span>กำลังส่ง...</span>
                </span>
            </button>

            <!-- Result -->
            <div id="form-result"></div>
        </form>
    </div>
</section>
