import fs from 'fs';
import yaml from 'js-yaml';

async function scan() {
    const file = fs.readFileSync('portals.yml', 'utf8');
    const doc = yaml.load(file);
    const positive = doc.title_filter.positive.map(k => k.toLowerCase());
    const negative = doc.title_filter.negative.map(k => k.toLowerCase());

    const companiesWithApi = doc.tracked_companies.filter(c => c.api && c.enabled !== false);
    let allMatches = [];

    await Promise.all(companiesWithApi.map(async (company) => {
        try {
            const res = await fetch(company.api);
            const data = await res.json();
            if (!data.jobs) return;
            
            data.jobs.forEach(job => {
                const titleLower = job.title.toLowerCase();
                const hasPositive = positive.some(p => titleLower.includes(p));
                const hasNegative = negative.some(n => titleLower.includes(n));
                
                if (hasPositive && !hasNegative) {
                    allMatches.push({
                        company: company.name,
                        title: job.title,
                        url: job.absolute_url,
                        location: job.location?.name || ''
                    });
                }
            });
        } catch(e) {
            console.error('Failed to fetch', company.name, e.message);
        }
    }));

    console.log(`Found ${allMatches.length} matching jobs via APIs!`);
    allMatches.slice(0, 15).forEach((m, i) => {
        console.log(`${i+1}. [${m.company}] ${m.title}`);
        console.log(`   Location: ${m.location}`);
        console.log(`   URL: ${m.url}\n`);
    });
}
scan();
