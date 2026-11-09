import { zones, type Pro } from '@kaarigor/shared/catalog';
import { useApp } from '../state/AppState';
export function AreaMap({
  value,
  onChange,
  pros = [],
  onPro,
}: {
  value: string;
  onChange: (id: string) => void;
  pros?: Pro[];
  onPro?: (p: Pro) => void;
}) {
  const { lang, L } = useApp();
  return (
    <div className="area-map">
      <div className="map-title">
        <span className="eyebrow">{L('DHAKA, BY NEIGHBOURHOOD', 'ঢাকা, এলাকাভিত্তিক')}</span>
        <span className="pill">{L('Tap to explore', 'এলাকা বেছে নিন')}</span>
      </div>
      <svg
        viewBox="0 0 520 530"
        role="group"
        aria-label={L(
          'Illustrative Dhaka area selector, not a navigation map',
          'ঢাকার চিত্রভিত্তিক এলাকা নির্বাচন, নেভিগেশন মানচিত্র নয়',
        )}
      >
        <defs>
          <pattern id="mapdots" width="18" height="18" patternUnits="userSpaceOnUse">
            <circle cx="2" cy="2" r=".7" fill="#8b9e85" opacity=".3" />
          </pattern>
        </defs>
        <rect width="520" height="530" fill="url(#mapdots)" />
        <path
          d="M475 0Q405 80 470 185T482 365Q455 470 510 530M20 0Q40 60 15 140T25 300Q-10 390 85 520"
          fill="none"
          stroke="var(--river)"
          strokeWidth="18"
          opacity=".6"
        />
        {zones.map((z) => (
          <g
            key={z.id}
            role="button"
            tabIndex={0}
            aria-label={z.name[lang]}
            aria-pressed={value === z.id}
            onClick={() => onChange(z.id)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                onChange(z.id);
              }
            }}
            className={value === z.id ? 'zone active' : 'zone'}
          >
            <path d={z.path} />
            <text x={z.x} y={z.y} textAnchor="middle">
              {z.name[lang].replace(' & ', ' / ')}
            </text>
          </g>
        ))}
        {pros.slice(0, 2).map((p, i) => {
          const z = zones.find((z) => z.id === p.zoneId)!;
          return (
            <g
              className="pro-pin"
              key={p.id}
              role="button"
              tabIndex={0}
              aria-label={L(`View ${p.name}`, `${p.bn}-এর প্রোফাইল দেখুন`)}
              onClick={() => onPro?.(p)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') onPro?.(p);
              }}
              transform={`translate(${z.x - 50 + i * 75},${z.y + 25})`}
            >
              <clipPath id={`avatar-clip-${p.id}`}>
                <circle cx="0" cy="0" r="20" />
              </clipPath>
              <circle r="24" fill="#fffdf5" stroke="#d1a76a" strokeWidth="2" />
              <image
                href={p.avatarImage || `/assets/avatars/${p.avatar}.jpg`}
                x="-20"
                y="-20"
                width="40"
                height="40"
                preserveAspectRatio="xMidYMid slice"
                clipPath={`url(#avatar-clip-${p.id})`}
              />
              <circle cx="18" cy="-16" r="7" fill="#3d7c51" stroke="#fff" strokeWidth="2" />
            </g>
          );
        })}
      </svg>
      <div className="map-foot">
        <span>
          <i />
          {L('Area-level sample profiles', 'এলাকাভিত্তিক নমুনা প্রোফাইল')}
        </span>
        <small>
          {L(
            'Illustrative zones · no exact locations',
            'চিত্রভিত্তিক এলাকা · সুনির্দিষ্ট অবস্থান নয়',
          )}
        </small>
      </div>
    </div>
  );
}
