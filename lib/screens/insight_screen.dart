import 'package:flutter/material.dart';
import '../models/insight_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class InsightScreen extends StatefulWidget {
  final String userId;

  const InsightScreen({
    super.key,
    required this.userId,
  });

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  late Future<InsightSummary> _insightFuture;

  @override
  void initState() {
    super.initState();
    _insightFuture = ApiService.getInsightSummary(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Search Insights'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _insightFuture =
                    ApiService.getInsightSummary(userId: widget.userId);
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh insights',
          ),
        ],
      ),
      body: FutureBuilder<InsightSummary>(
        future: _insightFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryYellow,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your insights...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            // Check if it's a server busy error
            final isServerBusy = snapshot.error.toString().contains('SERVER_BUSY') ||
                snapshot.error.toString().contains('Retry also timed out') ||
                snapshot.error.toString().contains('servers are busy');
            
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isServerBusy ? Icons.cloud_off : Icons.error_outline,
                      size: 80,
                      color: isServerBusy ? AppTheme.primaryYellow : AppTheme.accentRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isServerBusy ? 'Servers Busy' : 'Error Loading Insights',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isServerBusy
                          ? 'Servers are busy updating insights. Please wait a moment and try again...'
                          : snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _insightFuture = ApiService.getInsightSummary(
                            userId: widget.userId,
                          );
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return _buildEmptyState();
          }

          final insight = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards Grid
                _buildStatsSection(insight.stats),
                const SizedBox(height: 32),

                // Top Skills
                _buildTopSkillsSection(insight.skills),
                const SizedBox(height: 32),

                // Top Companies
                _buildTopCompaniesSection(insight.companies),
                const SizedBox(height: 32),

                // Top Locations
                _buildTopLocationsSection(insight.locations),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(InsightStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              title: 'Total Applications',
              value: '${stats.totalApplications}',
              icon: Icons.send,
              color: AppTheme.primaryYellow,
            ),
            _buildStatCard(
              title: 'Interviews',
              value: '${stats.totalInterviews}',
              icon: Icons.videocam,
              color: const Color(0xFF2196F3),
            ),
            _buildStatCard(
              title: 'Interview Rate',
              value: '${stats.interviewRate.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: const Color(0xFF4CAF50),
            ),
            _buildStatCard(
              title: 'Offers',
              value: '${stats.totalOffers}',
              icon: Icons.celebration,
              color: const Color(0xFFFF9800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSkillsSection(List<Skill> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Skills',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (skills.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No skill data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final skill = skills[index];
              final maxCount = skills.first.count.toDouble();
              final progress = skill.count / maxCount;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            skill.skill,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryYellow.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${skill.count}x',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.primaryYellow,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppTheme.surfaceColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryYellow,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTopCompaniesSection(List<Company> companies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Companies',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (companies.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No company data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${company.rank}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryYellow,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.company,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${company.count} application${company.count > 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${company.count}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTopLocationsSection(List<Location> locations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opportunities by Location',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (locations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No location data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.primaryYellow,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.location,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${location.count} job${location.count > 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2196F3).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${location.count}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                            color: const Color(0xFF2196F3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Insights Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Start applying to jobs to see insights about your job search progress, top skills, and opportunities.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
