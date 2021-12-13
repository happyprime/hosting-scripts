<?php

namespace HappyPrime\HostingScripts;

/**
 * Process a list of JSON files generated with WP-CLI for plugin updates
 * and publish it as a new issue in GitHub.
 */
function process_plugin_updates() {
	$body_text = '';

	foreach( glob( __DIR__ . '/plugin-updates/*.json' ) as $file ) {
		$file_name = explode( '/', $file );
		$file_name = str_replace( '-plugins.json', '', array_pop( $file_name ) );

		$json_contents = file_get_contents( $file );
		$json_contents = json_decode( $json_contents );

		if ( 0 === count( $json_contents ) ) {
			continue;
		}

		$body_text .= '## ' . $file_name . " plugin updates \n\n";

		foreach ( $json_contents as $plugin ) {
			if ( 'available' !== $plugin->update ) {
				continue;
			}

			$body_text .= '* [ ] Update ' . $plugin->name . ' (current version ' . $plugin->version . ")\n";
		}

		$body_text .= "\n";
		unset( $json_contents );
	}

	return $body_text;
}

/**
 * Create a new issue for the current date with any plugin updates
 * that should be completed for hosted projects.
 */
function post_new_issue() {
	$title_text = date( 'F j, Y') . ' Hosted plugin updates';
	$body_text  = process_plugin_updates();
	$bot_token  = file_get_contents( 'bot-token' );

	$new_issue_curl = curl_init( 'https://api.github.com/repos/happyprime/hosting/issues' );

	curl_setopt_array(
		$new_issue_curl,
		array(
			CURLOPT_CUSTOMREQUEST => 'POST',
			CURLOPT_POSTFIELDS    => json_encode(
				array(
					'title' => $title_text,
					'body' => $body_text,
				)
			),
			CURLOPT_HTTPHEADER    => array(
				'Accept: application/vnd.github.v3+json',
				'Content-Type: application/json',
				'Authorization: Token ' . $bot_token,
				'User-Agent: Happy Prime hosting script',
			)
		)
	);

	curl_exec( $new_issue_curl );
	curl_close( $new_issue_curl );
}

post_new_issue();
