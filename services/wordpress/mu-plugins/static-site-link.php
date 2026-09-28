<?php
/**
 * Plugin Name: Inception Static Site Link
 * Description: Adds a static site link to the WordPress home page.
 */

defined('ABSPATH') || exit;

add_action('wp_body_open', function () {
    if (!is_front_page()) {
        return;
    }
    echo '<nav aria-label="関連サイト" style="padding: 1rem; text-align: center;"><a href="/static/">static site</a></nav>';
});
