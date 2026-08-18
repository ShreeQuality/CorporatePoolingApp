-- ============================================================
-- Migration 017: Scheduled Automation & pg_cron Jobs
-- Source of Truth: SRS_Document.md (§9.6, §11.2, §14.3, §20.5)
-- Date: 18-Aug-2026
-- Run AFTER: 015_stored_procedures.sql & 016_database_triggers.sql
-- ============================================================

-- Enable pg_cron extension (requires superuser / Supabase SQL Editor)
CREATE EXTENSION IF NOT EXISTS "pg_cron";

-- ─── Helper Function: Auto-Unlock 24h Expired Ratings (§20.5) ─
CREATE OR REPLACE FUNCTION public.auto_unlock_expired_ratings()
RETURNS JSONB AS $$
DECLARE
    v_unlocked_count INT := 0;
BEGIN
    UPDATE public.ride_ratings
    SET is_locked = FALSE
    WHERE is_locked = TRUE
      AND created_at < NOW() - INTERVAL '24 hours';
    GET DIAGNOSTICS v_unlocked_count = ROW_COUNT;

    RETURN jsonb_build_object(
        'success', true,
        'unlocked_count', v_unlocked_count,
        'timestamp', NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ─── Helper Function: Expire Old Search Alerts (§5.2) ────────
CREATE OR REPLACE FUNCTION public.cleanup_expired_search_alerts()
RETURNS JSONB AS $$
DECLARE
    v_cleaned_count INT := 0;
BEGIN
    UPDATE public.search_alerts
    SET is_active = FALSE
    WHERE is_active = TRUE
      AND target_date < CURRENT_DATE;
    GET DIAGNOSTICS v_cleaned_count = ROW_COUNT;

    RETURN jsonb_build_object(
        'success', true,
        'deactivated_count', v_cleaned_count
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- PG_CRON SCHEDULED JOBS
-- Note: All times in pg_cron run in UTC timezone!
-- IST (Indian Standard Time) is UTC + 5 hours 30 minutes.
-- ============================================================

-- Unschedule existing jobs if re-running migration
DO $$
BEGIN
    PERFORM cron.unschedule('nightly-recurring-match');
    PERFORM cron.unschedule('monthly-corporate-grants');
    PERFORM cron.unschedule('hourly-escrow-healer');
    PERFORM cron.unschedule('hourly-review-unlocker');
    PERFORM cron.unschedule('daily-search-alert-cleanup');
EXCEPTION WHEN OTHERS THEN
    -- Ignore if jobs did not exist
END $$;

-- ─── 1. Nightly 8:00 PM IST Recurring Commute Matcher ─────────
-- 8:00 PM IST = 14:30 UTC
SELECT cron.schedule(
    'nightly-recurring-match',
    '30 14 * * *',
    'SELECT public.process_nightly_recurring_rides();'
);

-- ─── 2. 1st-of-the-Month 00:01 AM IST Corporate Grant Airdrop ─
-- 00:01 AM IST on 1st = 18:31 UTC on last day of previous month
SELECT cron.schedule(
    'monthly-corporate-grants',
    '31 18 1 * *',
    'SELECT public.distribute_monthly_corporate_grants();'
);

-- ─── 3. Hourly Stuck Escrow Self-Healer (> 4 Hours Old) ───────
-- Runs at minute 0 of every hour
SELECT cron.schedule(
    'hourly-escrow-healer',
    '0 * * * *',
    'SELECT public.reconcile_stuck_escrow();'
);

-- ─── 4. Hourly Double-Blind 24h Review Auto-Unlocker ──────────
-- Runs at minute 30 of every hour
SELECT cron.schedule(
    'hourly-review-unlocker',
    '30 * * * *',
    'SELECT public.auto_unlock_expired_ratings();'
);

-- ─── 5. Daily Midnight Search Alert Cleanup ───────────────────
-- Midnight IST (18:30 UTC)
SELECT cron.schedule(
    'daily-search-alert-cleanup',
    '30 18 * * *',
    'SELECT public.cleanup_expired_search_alerts();'
);

-- ============================================================
-- END OF MIGRATION 017
-- ============================================================
